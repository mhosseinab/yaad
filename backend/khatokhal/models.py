
import uuid
from django.db import models
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.utils.translation import gettext_lazy as _
from django.utils.functional import cached_property
from django.core.validators import MinValueValidator
from django.core.exceptions import ValidationError
from django.utils.text import Truncator
from django.conf import settings
from pathlib import Path
from urllib.parse import unquote_plus

from simple_history.models import HistoricalRecords

LESSON_CONTENT_TYPE_CHOICES = (
    ('T', 'Text'),
    ('V', 'Video'),
    ('I', 'Image'),
    ('A', 'Audio'),
)


def validate_media(value):
    value = unquote_plus(value)
    
    if value.startswith('/'):
        value = value[1:]
    
    if not (settings.MEDIA_ROOT.parent / value).is_file():
        raise ValidationError(
            _('%(value)s is not a valid file'),
            params={'value': value},
        )

class Book(models.Model):
    title = models.CharField(max_length=2048, db_index=True)
    subtitle = models.CharField(max_length=2048, db_index=True)
    author = models.CharField(default='', blank=True, max_length=2048, db_index=True)
    about = models.TextField(default='', blank=True)
    publisher = models.ForeignKey('Publisher', on_delete=models.PROTECT)
    course = models.ForeignKey('Course', on_delete=models.PROTECT)
    niveau = models.ForeignKey('Niveau', on_delete=models.PROTECT)
    image = models.CharField(max_length=4096, validators=[validate_media,])
    video = models.CharField(max_length=4096, null=True, blank=True, validators=[validate_media,])
    price = models.PositiveIntegerField(default=1000)
    discount = models.FloatField(default=0.0)
    rate = models.FloatField(default=0)
    rate_count = models.IntegerField(default=0)
    purchase_count = models.IntegerField(default=0)
    is_promoted = models.BooleanField(default=False)
    is_draft = models.BooleanField(default=False)
    is_yaad = models.BooleanField(default=False)
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    def get_discount(self):
        discount = 0
        if self.discount:
            if self.discount < 100:
                discount = int(self.discount / 100 * self.price)
            else:
                discount = self.discount
        return discount
    
    @cached_property
    def step_count(self):
        chapters = self.chapter_set.all()
        count = 0
        for c in chapters:
            if self.is_yaad:
                for s in c.steps:
                    count += len(s)
            else:
                count += len(c.steps)
        return count
    
    @cached_property
    def comments(self):
        return self.usercomment_set.all()[:5]
    
    def __str__(self):
        return self.title + (' | یاد' if self.is_yaad else '')


class Publisher(models.Model):
    title = models.CharField(max_length=2048)
    logo = models.ForeignKey('app.Media', on_delete=models.PROTECT,
                             null=True, blank=True, related_name='khatokhal_publisher_media_set')
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

class Niveau(models.Model):
    title = models.CharField(max_length=256)
    order = models.SmallIntegerField(default=0)
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

class Course(models.Model):
    title = models.CharField(max_length=256)
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

class Chapter(models.Model):
    title = models.CharField(max_length=2048)
    book = models.ForeignKey('Book', on_delete=models.CASCADE)
    row = models.PositiveSmallIntegerField(default=0)
    steps = models.JSONField(default=list, blank=True, null=True)
    is_draft = models.BooleanField(default=False)
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    def __str__(self):
        return "{} | {}".format(self.book.title, self.title)

class Section(models.Model):
    title = models.CharField(max_length=2048)
    chapter = models.ForeignKey('Chapter', on_delete=models.CASCADE)
    row = models.PositiveSmallIntegerField(default=0)
    steps = models.JSONField(default=list, blank=True, null=True)
    is_draft = models.BooleanField(default=False)
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    def __str__(self):
        return "{} | {}".format(self.chapter.title, self.title)

class Lesson(models.Model):
    book = models.ForeignKey('Book', on_delete=models.CASCADE)
    title = models.CharField(max_length=2048, null=True, blank=True)
    text = models.TextField(null=True, blank=True)
    content_type = models.CharField(max_length=1, choices=LESSON_CONTENT_TYPE_CHOICES)
    media = models.CharField(max_length=4096, null=True, blank=True, validators=[validate_media,])
    is_draft = models.BooleanField(default=False)
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    def __str__(self):
        return Truncator(self.text).words(10) if self.text else self.media or "no-title"

class Question(models.Model):
    book = models.ForeignKey('Book', on_delete=models.CASCADE)
    text = models.TextField(null=True, blank=True)
    content_type = models.CharField(max_length=1, choices=LESSON_CONTENT_TYPE_CHOICES)
    media = models.CharField(max_length=4096, null=True, blank=True, validators=[validate_media,])
    is_draft = models.BooleanField(default=False)
    answer_choices = models.JSONField()
    answer = models.JSONField()
    is_draft = models.BooleanField(default=False)
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    def __str__(self):
        return Truncator(self.text).words(10) if self.text else self.media or "no-title"

STEP_CHOICES = models.Q(app_label='khatokhal', model='lesson') | models.Q(
    app_label='khatokhal', model='question') | models.Q(app_label='khatokhal', model='section')

class Step(models.Model):
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE, limit_choices_to=STEP_CHOICES)
    content_id = models.PositiveIntegerField()
    content = GenericForeignKey('content_type', 'content_id')
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)


class Slide(models.Model):
    title = models.CharField(max_length=2048, null=True, blank=True)
    url = models.TextField(null=True, blank=True)
    media = models.ForeignKey('app.Media', on_delete=models.PROTECT,null=True, blank=True, related_name='khatokhal_banner_media_set')
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

class Purchase(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.PROTECT)
    books = models.ManyToManyField('Book', blank=True)
    history = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)
    def __str__(self):
        return str(self.user)

INVOICE_ITEM_CHOICES = models.Q(app_label='khatokhal', model='book')
class INVOICE_STATUS(models.IntegerChoices):
    PENDING  = 0, 'pending'
    SUCCESS  = 1, 'success'
    FAILED   = 2, 'failed'
    REFUNDED = 5, 'refunded'
class Invoice(models.Model):
    uuid      = models.UUIDField(default=uuid.uuid4, editable=False, unique=True, db_index=True)
    user      = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT)
    item_type = models.ForeignKey(ContentType, on_delete=models.CASCADE, limit_choices_to=INVOICE_ITEM_CHOICES)
    item_id   = models.PositiveIntegerField()
    item      = GenericForeignKey('item_type', 'item_id')
    price     = models.PositiveIntegerField()
    discount  = models.PositiveIntegerField(default=0)
    status    = models.PositiveSmallIntegerField(choices=INVOICE_STATUS.choices, default=0)
    history   = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    @property
    def total(self):
        return max(self.price - self.discount, 100)
    
    @property
    def payments(self):
        return self.payment_set.all()
    
    def __str__(self):
        return f'{str(self.user.mobile)} | {str(self.uuid)}'

class PAYMENT_STATUS(models.IntegerChoices):
    INITIATED     = 0, 'initiated'
    SUCCESS       = 1, 'success'
    FAILED        = 2, 'failed'
    UNVERIFIED    = 3, 'unverified'
    GATEWAY_ERROR = 4, 'gateway error'
    REFUNDED      = 5, 'refunded'
class Payment(models.Model):
    uuid      = models.UUIDField(default=uuid.uuid4, editable=False, unique=True, db_index=True)
    invoice   = models.ForeignKey('Invoice', on_delete=models.CASCADE)
    gateway   = models.CharField(max_length=150)
    amount    = models.IntegerField(validators=[MinValueValidator(1000)])
    recipt    = models.CharField(max_length=300,null=True,blank=True)
    tid       = models.CharField(max_length=300,null=True,blank=True)
    card      = models.CharField(max_length=50,null=True,blank=True,default=None)
    trace     = models.CharField(max_length=50,null=True,blank=True,default=None)
    status    = models.PositiveSmallIntegerField(choices=PAYMENT_STATUS.choices, default=0)
    note      = models.TextField(blank=True, null=True)
    history   = HistoricalRecords()
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)
    def __str__(self):
        return str(self.uuid)

class UserRate(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='khatokhal_rates')
    book = models.ForeignKey('Book', on_delete=models.CASCADE)
    rate = models.IntegerField()
    createdAt = models.DateTimeField(auto_now_add=True)         
    updatedAt = models.DateTimeField(auto_now=True)
    def __str__(self):
        return str(self.rate)

class UserComment(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='khatokhal_comments')
    book = models.ForeignKey('Book', on_delete=models.PROTECT)
    rate = models.ForeignKey('UserRate', on_delete=models.CASCADE, null=True, blank=True)
    parent = models.ForeignKey('UserComment', null=True, on_delete=models.SET_NULL)
    text = models.TextField()
    is_deleted = models.BooleanField(default=False)
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)
    class Meta:
        ordering = ('-pk', )
