from django.db import models
from django.utils.translation import gettext_lazy as _
from simple_history.models import HistoricalRecords

class Slide(models.Model):
    title = models.CharField(max_length=2048, null=True, blank=True)
    url = models.TextField(null=True, blank=True)
    media = models.ForeignKey('app.Media', on_delete=models.PROTECT,null=True, blank=True, related_name='yaad_banner_media_set')
    row = models.PositiveSmallIntegerField(default=0)
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)
    def __str__(self):
        print(self.media)
        return self.title or str(self.media)

class STORE_ROW_CHOICES(models.TextChoices):
    SLIDE  = 'S', 'slide'
    BOOK   = 'B', 'book'

class StoreRow(models.Model):
    title      = models.CharField(max_length=2048, null=True, blank=True)
    show_title = models.BooleanField(default=False)
    items      = models.JSONField(default=list)
    item_type  = models.CharField(max_length=1, choices=STORE_ROW_CHOICES.choices, default='B')
    row        = models.PositiveSmallIntegerField(default=0)
    history    = HistoricalRecords()
    createdAt  = models.DateTimeField(auto_now_add=True)
    updatedAt  = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return str(self.items)

