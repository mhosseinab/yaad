from rest_framework import generics, mixins, status
from rest_framework.response import Response
from rest_framework.pagination import LimitOffsetPagination, PageNumberPagination
from rest_framework.permissions import IsAuthenticated, IsAdminUser, BasePermission, SAFE_METHODS

from .models import Slide, StoreRow
from .serializers import StoreRowSerializer, SlideSerializer
from .filters import SlideFilter
class ReadOnly(BasePermission):
    def has_permission(self, request, view):
        return request.method in SAFE_METHODS


class IsStaffUser(BasePermission):
    """
    Allows access only to admin users.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_staff

class IsStaffUser(BasePermission):
    """
    Allows access only to admin users.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_staff

class GenericView(mixins.ListModelMixin,
                  mixins.RetrieveModelMixin,
                  mixins.CreateModelMixin,
                  mixins.DestroyModelMixin,
                  mixins.UpdateModelMixin,
                  generics.GenericAPIView):
    permission_classes = [IsStaffUser | ReadOnly]
    def options(self, request, *args, **kwargs):
        if self.metadata_class is None:
            return self.http_method_not_allowed(request, *args, **kwargs)
        pk = kwargs.get('pk')
        if not pk:
            return Response(status=status.HTTP_204_NO_CONTENT)
        data = self.metadata_class().determine_metadata(request, self)
        return Response(data, status=status.HTTP_200_OK)

    def get(self, request, *args, **kwargs):
        pk = kwargs.get('pk')
        if pk:
            return self.retrieve(request, *args, **kwargs)
        return self.list(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)

    def put(self, request, *args, **kwargs):
        pk = kwargs.get('pk')
        if not pk:
            return self.http_method_not_allowed(request, *args, **kwargs)
        return self.update(request, *args, **kwargs)

    def patch(self, request, *args, **kwargs):
        pk = kwargs.get('pk')
        if not pk:
            return self.http_method_not_allowed(request, *args, **kwargs)
        return self.partial_update(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        pk = kwargs.get('pk')
        if not pk:
            return self.http_method_not_allowed(request, *args, **kwargs)
        return self.destroy(request, *args, **kwargs)

class Slides(GenericView):
    queryset = Slide.objects.all().prefetch_related('media',).order_by('row', '-pk')
    serializer_class = SlideSerializer
    filterset_class = SlideFilter

class StoreRows(GenericView):
    queryset = StoreRow.objects.all().order_by('row', '-pk')
    serializer_class = StoreRowSerializer