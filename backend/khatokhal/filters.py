from django.db.models import Q
from django_filters import rest_framework as filters
from rest_framework import fields

from .models import *

class BookFilter(filters.FilterSet):
  title = filters.CharFilter(lookup_expr='icontains')
  subtitle = filters.CharFilter(lookup_expr='icontains')
  ititle = filters.CharFilter(method='search_title')
  is_draft = filters.BooleanFilter(field_name='is_draft')
  
  o = filters.OrderingFilter(
    fields=(
      ('updatedAt', 'updatedAt'),
      ('rate', 'rate'),
      ('title', 'title'),
      ('is_promoted', 'is_promoted'),
      ('id', 'id'),
      ('price', 'price'),
      ('is_draft', 'is_draft'),
      ('niveau', 'niveau'),
      ('course', 'course'),
      ('publisher', 'publisher'),
    ),
  )

  def search_title(self, queryset, name, value):
    return Book.objects.filter( Q(title__icontains=value) | Q(subtitle__icontains=value) )
  
  class Meta:
    model = Book
    fields = ['id', 'is_promoted', 'title', 'subtitle', 'ititle', 'publisher']

class PublisherFilter(filters.FilterSet):
  title = filters.CharFilter(lookup_expr='icontains')
  class Meta:
    model = Publisher
    fields  = ['id', 'title']

class ChapterFilter(filters.FilterSet):
  title = filters.CharFilter(lookup_expr='icontains')

  o = filters.OrderingFilter(
    fields=(
      ('row', 'row'),
    ),
  )
  class Meta:
    model = Chapter
    fields = ['id', 'book', 'title']

class SectionFilter(filters.FilterSet):
  title = filters.CharFilter(lookup_expr='icontains')

  class Meta:
    model = Section
    fields = ['id', 'chapter', 'title']

class LessonFilter(filters.FilterSet):

  class Meta:
    model = Lesson
    fields = ['id', 'book', 'content_type']


class QuestionFilter(filters.FilterSet):

  class Meta:
    model = Question
    fields = ['id', 'book', 'content_type']

class NiveauFilter(filters.FilterSet):
  title = filters.CharFilter(lookup_expr='icontains')

  class Meta:
    model = Niveau
    fields = ['id', 'title', 'order']

class CourseFilter(filters.FilterSet):
  title = filters.CharFilter(lookup_expr='icontains')

  class Meta:
    model = Course
    fields = ['id', 'title']

class StepFilter(filters.FilterSet):

  class Meta:
    model = Step
    fields = ['id', 'content_id']

class SlideFilter(filters.FilterSet):

  class Meta:
    model = Slide
    fields = ['id', ]

class UserCommentFilter(filters.FilterSet):
  no_parent = filters.BooleanFilter(field_name='parent', lookup_expr='isnull')
  class Meta:
    model = UserComment
    fields = ['book', 'parent' ]
