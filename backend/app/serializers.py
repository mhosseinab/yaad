from rest_framework import serializers

from .models import Media

class MediaUploadSerializer(serializers.ModelSerializer):
  class Meta:
    model = Media
    fields = '__all__'

class MediaSerializer(serializers.ModelSerializer):
  url = serializers.SerializerMethodField()
  def get_url(self, obj):
    request = self.context.get('request')
    return request.build_absolute_uri(obj.file.url)
  class Meta:
    model = Media
    fields = ['id', 'url', 'title']