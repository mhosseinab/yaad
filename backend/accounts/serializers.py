
from hashlib    import md5
from rest_framework import serializers
from django.core.validators import RegexValidator

from .models import User, UserProfile

class MobileAuthSerializer(serializers.Serializer):
    phone_regex = RegexValidator(
        regex=r'^98\d{10}$',  message="Mobile number is invalid")
    mobile = serializers.CharField(validators=[phone_regex], max_length=12)


class VerifyAuthSerializer(serializers.Serializer):
    uuid = serializers.UUIDField()
    token = serializers.CharField(max_length=6, validators=[
                                  RegexValidator(regex=r'^\d{4,6}$',  message="Token is invalid")])



class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        exclude = ['user', 'id']

class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(required=False)
    avatar = serializers.SerializerMethodField()
    
    def get_avatar(self, obj):
        return f'https://www.gravatar.com/avatar/{md5(obj.email.lower().encode("utf-8")).hexdigest()}?s=100' if obj.email else None
    class Meta:
        model = User
        fields = ['id', 'mobile', 'email', 'first_name', 'last_name', 'profile', 'avatar']