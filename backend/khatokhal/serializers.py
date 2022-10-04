
from hashlib    import md5
from django.db.models.query import QuerySet
from django.db.models import Case, When
from rest_framework import serializers
from django.conf import settings
from django.utils.text import slugify

from .models import *
from .filters import *
from app.serializers import MediaSerializer
from accounts.models import User

def filter__in_preserve(queryset: QuerySet, field: str, values: list) -> QuerySet:
    """
    .filter(field__in=values), preserves order.
    """
    # (There are not going to be missing cases, so default=len(values) is unnecessary)
    preserved = Case(*[When(**{field: val}, then=pos) for pos, val in enumerate(values)])
    return queryset.filter(**{f'{field}__in': values}).order_by(preserved)

class UserSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()
    avatar = serializers.SerializerMethodField()
    
    def get_avatar(self, obj):
        return f'https://www.gravatar.com/avatar/{md5(obj.email.lower().encode("utf-8")).hexdigest()}?s=100' if obj.email else None
    
    def get_name(self, obj):
        return f'{obj.first_name} {obj.last_name}' if obj.first_name or obj.last_name else None
    
    class Meta:
        model = User
        fields = ['id', 'name', 'avatar']

class PublisherSerializer(serializers.ModelSerializer):
    logo = MediaSerializer()

    class Meta:
        model = Publisher
        exclude = ['createdAt', 'updatedAt']


class ChapterSerializer(serializers.ModelSerializer):

    class Meta:
        model = Chapter
        exclude = ['createdAt', 'updatedAt']

    def to_representation(self, instance):
        response = super().to_representation(instance)
        response['steps'] = []
        if instance.steps and type(instance.steps)==list:
            if instance.book.is_yaad:
                for steps in instance.steps:
                    if type(steps)==list:
                        step_data = Step.objects.all().in_bulk(steps)
                        _data = []
                        for pk in steps:
                            if(step_data.get(pk)):
                                _data.append(StepSerializer(
                                    instance=step_data.get(pk),
                                    context=self.context
                                ).data)
                        response['steps'].append(_data)
                    else:
                        continue
            else:
                step_data = Step.objects.all().in_bulk(instance.steps)
                for pk in instance.steps:
                    if(step_data.get(pk)):
                        response['steps'].append(StepSerializer(
                            instance=step_data.get(pk),
                            context=self.context
                        ).data)
        return response

class ChapterListSerializer(serializers.ModelSerializer):
    step_count = serializers.SerializerMethodField()
    class Meta:
        model = Chapter
        exclude = ['row', 'is_draft', 'book', 'steps', 'createdAt', 'updatedAt']

    def get_step_count(self, obj):
        return len(obj.steps) if isinstance(obj.steps, list) else 0

class SectionSerializer(serializers.ModelSerializer):
    chapter = serializers.PrimaryKeyRelatedField(queryset=Chapter.objects.all())
    class Meta:
        model = Section
        exclude = ['createdAt', 'updatedAt']

    def to_representation(self, instance):
        response = super().to_representation(instance)
        if instance.steps:
            step_data = Step.objects.all().prefetch_related('content').in_bulk(instance.steps)
            response['steps'] = []
            for pk in instance.steps:
                if(step_data.get(pk)):
                    response['steps'].append(StepSerializer(
                        instance=step_data.get(pk),
                        context=self.context
                    ).data)
        else:
            response['steps'] = []
        return response

class LessonSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lesson
        exclude = ['createdAt', 'updatedAt']
    
    def to_representation(self, instance):
        response = super().to_representation(instance)
        if instance.media:
            response['media'] = self.context.get('request').build_absolute_uri(instance.media)
        return response

class JSONAnswerSerializer(serializers.Field):
    
    def to_internal_value(self, data):
        return data
    
    def to_representation(self, value):
        # print('media', value)
        if 'media' in value:
            value['media'] = self.context.get('request').build_absolute_uri(value['media'])
        return value
class QuestionSerializer(serializers.ModelSerializer):
    answer = JSONAnswerSerializer()
    class Meta:
        model = Question
        exclude = ['createdAt', 'updatedAt']
    
    def to_representation(self, instance):
        response = super().to_representation(instance)
        if instance.media:
            response['media'] = self.context.get('request').build_absolute_uri(instance.media)
        return response

class NiveauSerializer(serializers.ModelSerializer):

    class Meta:
        model = Niveau
        fields = ['id', 'title']

class CourseSerializer(serializers.ModelSerializer):

    class Meta:
        model = Course
        fields = ['id', 'title']

class BookRateSerializer(serializers.ModelSerializer):
    rate = serializers.IntegerField(required=True, max_value=5, min_value=1)
    class Meta:
        model = UserRate
        fields = ['book', 'rate']

class UserCommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    rate = BookRateSerializer()

    def validate_user(self, value):
        # print('validate_user', value)
        if self.context.get('request') and value != self.context.get('request').user:
            raise serializers.ValidationError("user integrity failed!")
        return value
    def to_representation(self, instance):
        response = super().to_representation(instance)
        response['rate'] = instance.rate.rate if instance.rate else 0
        return response
    class Meta:
        model = UserComment
        exclude = ['createdAt', 'updatedAt', 'is_deleted']

class BookSerializer(serializers.ModelSerializer):
    step_count = serializers.IntegerField(read_only=True)
    comments   = UserCommentSerializer(many=True, read_only=True)    

    class Meta:
        model = Book
        exclude = ['createdAt', 'updatedAt']
    
    def to_representation(self, instance):
        response = super().to_representation(instance)
        response['image'] = self.context.get('request').build_absolute_uri(instance.image) if instance.image else None
        response['video'] = self.context.get('request').build_absolute_uri(instance.video) if instance.video else None
        response['niveau']    = NiveauSerializer(instance.niveau, context=self.context).data
        response['course']    = CourseSerializer(instance.course, context=self.context).data
        response['publisher'] = PublisherSerializer(instance.publisher, context=self.context).data
        user = self.context.get('request').user
        if user and user.is_authenticated:
            response['is_purchased'] = instance.purchase_set.filter(user=user).exists()
            response['user_rate'] = instance.userrate_set.filter(user=user).first().rate if instance.userrate_set.filter(user=user).exists() else None
        else:
            response['is_purchased'] = False
            response['user_rate'] = None
        return response

class StepTypeSerializer(serializers.RelatedField):
    def to_representation(self, value):
        if isinstance(value, Lesson):
            return LessonSerializer(value, context=self.context).data
        elif isinstance(value, Question):
            return QuestionSerializer(value, context=self.context).data
        elif isinstance(value, Section):
            return SectionSerializer(value, context=self.context).data
        raise Exception('Unexpected type of Step')

class StepSerializer(serializers.ModelSerializer):
    content = StepTypeSerializer(read_only=True)
    type = serializers.SerializerMethodField()

    class Meta:
        model = Step
        fields = ('id', 'content', 'content_id', 'content_type', 'type')

    def get_type(self, obj):
        return obj.content_type.name

class SlideSerializer(serializers.ModelSerializer):
    class Meta:
        model = Slide
        exclude = ['createdAt', 'updatedAt']

    def to_representation(self, instance):
        response = super().to_representation(instance)
        response['media'] = MediaSerializer(
            instance.media, context=self.context).data.get('url') if instance.media else None
        return response

class StoreRowSerializer(serializers.ModelSerializer):
    class Meta:
        model = StoreRow
        exclude = ['createdAt', 'updatedAt']
    def to_representation(self, instance):
        response = super().to_representation(instance)
        if instance.item_type == STORE_ROW_CHOICES.BOOK:
            response['items'] = BookSerializer(
                filter__in_preserve(Book.objects.exclude(is_draft=True),'id',instance.items), 
                context=self.context, many=True, read_only=True).data
        elif instance.item_type == STORE_ROW_CHOICES.SLIDE:
            response['items'] = SlideSerializer(
                filter__in_preserve(Slide.objects.all(),'id',instance.items), 
                context=self.context, many=True, read_only=True).data

        return response

class PurchaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Purchase
        exclude = ['updatedAt', 'createdAt', 'user']
    def to_representation(self, instance):
        response = super().to_representation(instance)
        
        is_yaad = '/yaad/' in self.context.get('request').path

        response['books'] = BookSerializer(instance.books.filter(is_yaad=is_yaad), context=self.context, many=True).data

        return response

class IDPayResponseSerializer(serializers.Serializer):
    id = serializers.CharField()
    track_id = serializers.CharField()
    order_id = serializers.UUIDField()
