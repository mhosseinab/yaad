from rest_framework.views import APIView
from rest_framework import generics, mixins
from rest_framework import status
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.permissions import IsAuthenticated

from .notifications import send_auth_sms_token
from . import models
from . import serializers


class GetToken(APIView):
    serializer_class = serializers.MobileAuthSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(
            data=request.data, context={'request': request})
        if not serializer.is_valid(raise_exception=True):
            return Response(serializer.error_messages, status=status.HTTP_400_BAD_REQUEST)
        # CREATE USER IF NOT EXISTS
        user, _ = models.User.objects.get_or_create(mobile=serializer.validated_data['mobile'])
        
        if not user.is_active:
            return Response({'success': False, 'error': 'Inactive User'}, status=status.HTTP_403_FORBIDDEN)

        auth, created = models.AuthToken.objects.get_or_create(user=user)
        if created or auth.is_expired or not auth.is_active:
            is_yaad = request.GET.get('is_yaad') != None 
            auth.token = models.AuthToken.generate_numeric_token(length= 4 if is_yaad else 6)
            auth.is_active = True
            success = send_auth_sms_token(auth, is_yaad)
            if not success:
                return Response({'success': False, 'error': 'SMS failed'}, status=status.HTTP_424_FAILED_DEPENDENCY)
            auth.save()

        return Response({'success': True, 'uuid': auth.uid}, status=status.HTTP_200_OK)


class VerifyToken(APIView):
    serializer_class = serializers.VerifyAuthSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(
            data=request.data, context={'request': request})
        if not serializer.is_valid(raise_exception=True):
            return Response(serializer.error_messages, status=status.HTTP_400_BAD_REQUEST)
        try:
            auth = models.AuthToken.objects.get(
                uid=serializer.validated_data['uuid'])
        except models.AuthToken.DoesNotExist:
            return Response({'success': False}, status=status.HTTP_409_CONFLICT)

        if not auth.is_active or auth.is_expired or auth.token != serializer.validated_data['token']:
            # print(serializer.validated_data)
            # print(auth.is_active, auth.is_expired, auth.token)
            return Response({'success': False}, status=status.HTTP_403_FORBIDDEN)

        # disable token

        auth.is_active = False
        auth.save()

        # generate new token
        token, created = Token.objects.get_or_create(user=auth.user)
        # if not created:
        #     token.key = Token.generate_key()
        #     Token.objects.filter(user=auth.user).update(key=token.key)

        return Response({'success': True, 'data': {
            'token': token.key,
            'id': auth.user.pk,
            'mobile': auth.user.mobile,
            'first_name': auth.user.first_name,
            'last_name': auth.user.last_name,

        }}, status=status.HTTP_200_OK)


class UpdateProfile(generics.GenericAPIView,
                    mixins.RetrieveModelMixin,
                    mixins.UpdateModelMixin):
    
    queryset = models.User.objects.filter(is_active=True)
    serializer_class = serializers.UserSerializer
    permission_classes = [IsAuthenticated,]

    def get(self, request, *args, **kwargs):
        if self.get_object() != request.user:
            return Response({'success': False}, status=status.HTTP_403_FORBIDDEN)
        return self.retrieve(request, *args, **kwargs)

    def put(self, request, *args, **kwargs):
        if self.get_object() != request.user:
            return Response({'success': False}, status=status.HTTP_403_FORBIDDEN)
        
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data={**request.data, 'mobile':instance.mobile}, partial=partial)
        serializer.is_valid(raise_exception=True)

        if 'profile' in serializer.validated_data:
            profile_data = serializer.validated_data.pop('profile')
            profile = instance.profile
            
            profile.yob = profile_data.get('yob', profile.yob)
            profile.city = profile_data.get('city', profile.city)
            profile.is_student = profile_data.get('is_student', profile.is_student)
            profile.field_of_study = profile_data.get('field_of_study', profile.field_of_study)
            profile.save()

        serializer.save()
        
        return Response(serializer.data)
