import string
import uuid
from datetime import timedelta

from django.db import models
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.dispatch import receiver
from django.db.models.signals import post_save
from django.core.validators import RegexValidator, MinValueValidator, MaxValueValidator
from django.utils.crypto import get_random_string
from django.utils import timezone

from .managers import UserManager

class User(AbstractBaseUser, PermissionsMixin):
  mobile =  models.CharField(_('mobile'), max_length=12, validators=[RegexValidator(r'\d{12}')], unique=True, db_index=True)
  first_name = models.CharField(_('first name'), max_length=150, blank=True)
  last_name = models.CharField(_('last name'), max_length=150, blank=True)
  email = models.EmailField(_('email address'), blank=True)
  is_staff = models.BooleanField(
      _('staff status'),
      default=False,
      help_text=_('Designates whether the user can log into this admin site.'),
  )
  is_active = models.BooleanField(
      _('active'),
      default=True,
      help_text=_(
          'Designates whether this user should be treated as active. '
          'Unselect this instead of deleting accounts.'
      ),
  )
  date_joined = models.DateTimeField(_('date joined'), default=timezone.now)

  objects = UserManager()

  EMAIL_FIELD = 'email'
  USERNAME_FIELD = 'mobile'
  REQUIRED_FIELDS = []

  objects = UserManager()

  def __str__(self):
    return self.mobile

class STUDY_FIELD_CHOICES(models.IntegerChoices):
    RIAZI   = 1, 'ریاضی'
    TAJROBI = 2, 'تجربی'
    ENSANI  = 3, 'انسانی'
    HONAR   = 4, 'هنر'
    ZABAN   = 5, 'زبان'

class UserProfile(models.Model):
    user           = models.OneToOneField(User, related_name="profile", on_delete=models.CASCADE)
    field_of_study = models.PositiveSmallIntegerField(choices=STUDY_FIELD_CHOICES.choices, null=True, blank=True)
    yob            = models.PositiveSmallIntegerField(validators=[MinValueValidator(1300), MaxValueValidator(1400)], null=True, blank=True)
    city           = models.CharField(max_length=100, null=True, blank=True)
    is_student     = models.BooleanField(default=False)

    def __str__(self):
        return str(self.user)

@receiver(post_save, sender=User)
def create_profile_for_new_user(sender, created, instance, **kwargs):
    if created:
        profile = UserProfile(user=instance)
        profile.save()

class AuthToken(models.Model):
    uid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False, unique=True, db_index=True)
    user = models.ForeignKey(User, related_name=None, on_delete=models.CASCADE)
    token = models.CharField(max_length=6)
    is_active = models.BooleanField(default=True)
    createdAt = models.DateTimeField(auto_now_add=True)
    updatedAt = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        if not self.token:
            self.token = self.generate_numeric_token()
        return super().save(*args, **kwargs)
    
    @classmethod
    def generate_numeric_token(cls, length=6):
        """
        Generate a random 6 digit string of numbers.
        We use this formatting to allow leading 0s.
        """
        return get_random_string(length=length, allowed_chars=string.digits)

    @property
    def is_expired(self):
        return self.updatedAt < timezone.now()  - timedelta(minutes=2)