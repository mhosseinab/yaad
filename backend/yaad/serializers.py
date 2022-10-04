from django.db.models.query import QuerySet
from django.db.models import Case, When
from rest_framework import serializers

from .models import *
from app.serializers import MediaSerializer
from khatokhal.models import Book
from khatokhal.serializers import BookSerializer

def filter__in_preserve(queryset: QuerySet, field: str, values: list) -> QuerySet:
    """
    .filter(field__in=values), preserves order.
    """
    # (There are not going to be missing cases, so default=len(values) is unnecessary)
    preserved = Case(*[When(**{field: val}, then=pos) for pos, val in enumerate(values)])
    return queryset.filter(**{f'{field}__in': values}).order_by(preserved)


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
