from django.contrib import admin
from django.utils.translation import gettext, gettext_lazy as _
from django.contrib.auth.admin import UserAdmin as AuthUserAdmin
from import_export.admin import ExportActionMixin, ExportMixin

from .models import *


@admin.register(UserProfile)
class UserProfileAdmin(ExportMixin, admin.ModelAdmin):
  list_display = ('id','user','field_of_study','yob','city','is_student')
  raw_id_fields = ['user']
  search_fields = ('id', 'user__mobile','user__email','user__id',)
  list_filter = ('is_student',)
  ordering = ('-id',)

@admin.register(AuthToken)
class AuthTokenAdmin(admin.ModelAdmin):
  list_display = ('pk','uid','user','token','is_active')
  raw_id_fields = ['user']
  search_fields = ('user__mobile','user__email','user__id',)
  list_filter = ('is_active',)
  ordering = ('-pk',)

@admin.register(User)
class UserAdmin(ExportMixin, AuthUserAdmin):
  fieldsets = (
    (None, {'fields': ('mobile', 'password')}),
    (_('Personal info'), {'fields': ('first_name', 'last_name', 'email')}),
    (_('Permissions'), {
        'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions'),
    }),
    (_('Important dates'), {'fields': ('last_login', 'date_joined')}),
  )
  add_fieldsets = (
    (None, {
        'classes': ('wide',),
        'fields': ('mobile', 'password1', 'password2'),
    }),
  )
  list_display = ('id', 'mobile', 'email', 'first_name', 'last_name', 'is_staff')
  list_filter = ('is_staff', 'is_superuser', 'is_active', 'date_joined', 'last_login', 'groups')
  search_fields = ('id', 'mobile', 'first_name', 'last_name', 'email')
  ordering = ('-is_staff','-id',)