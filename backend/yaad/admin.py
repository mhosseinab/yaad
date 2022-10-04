from django.contrib import admin
from simple_history.admin import SimpleHistoryAdmin

from .models import *

admin.site.register(Slide, SimpleHistoryAdmin)
admin.site.register(StoreRow, SimpleHistoryAdmin)