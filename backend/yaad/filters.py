from django_filters import rest_framework as filters

from .models import *
class SlideFilter(filters.FilterSet):

  class Meta:
    model = Slide
    fields = ['id', ]