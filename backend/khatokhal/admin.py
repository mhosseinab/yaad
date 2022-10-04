from django.contrib import admin
from django.utils.safestring import mark_safe

from simple_history.admin import SimpleHistoryAdmin

from .models import *

admin.site.register(Publisher, SimpleHistoryAdmin)
admin.site.register(Chapter, SimpleHistoryAdmin)
admin.site.register(Section, SimpleHistoryAdmin)
admin.site.register(Lesson, SimpleHistoryAdmin)
admin.site.register(Question, SimpleHistoryAdmin)
admin.site.register(Course, SimpleHistoryAdmin)
admin.site.register(Niveau, SimpleHistoryAdmin)
admin.site.register(Step, SimpleHistoryAdmin)
admin.site.register(Slide, SimpleHistoryAdmin)
admin.site.register(StoreRow, SimpleHistoryAdmin)

class UserRateList(admin.ModelAdmin):
#     actions = ['activate_users', 'resend_activation_email']
    list_display = ('id','user','book','rate', )
    list_filter = ('createdAt', 'book',)
    raw_id_fields = ['user']
    search_fields = ('id','book__title','user__mobile')
    
admin.site.register(UserRate, UserRateList)

class UserCommentList(admin.ModelAdmin):
#     actions = ['activate_users', 'resend_activation_email']
    list_display = ('id','user','book','rate', 'text')
    list_filter = ('createdAt', 'book',)
    raw_id_fields = ['user']
    search_fields = ('id','book__title','user__mobile')
    
admin.site.register(UserComment, UserCommentList)

class InvoiceList(SimpleHistoryAdmin):
#     actions = ['activate_users', 'resend_activation_email']
    list_display = ('id','user','item','price','discount','status','createdAt',)
    list_filter = ('status','createdAt')
    raw_id_fields = ['user']
    search_fields = ('id','uuid','user__mobile')
    
admin.site.register(Invoice,InvoiceList)

class PaymentList(SimpleHistoryAdmin):
#     actions = ['activate_users', 'resend_activation_email']
    list_display = ('id','view_invoice','view_item','gateway','amount','status','createdAt',)
    list_filter = ('status','createdAt',)
    raw_id_fields = ['invoice']
    search_fields = ('id','uuid','invoice__user__mobile','trace','tid')
    
    def view_invoice(self, obj):
        if obj.invoice:
            return mark_safe(f'<a target="_blank" href="/admin/khatokhal/invoice/?q={obj.invoice.uuid}" class="changelink">{obj.invoice.user}</a>')
        return ''
    view_invoice.short_description = 'user'
    
    def view_item(self, obj):
        if obj.invoice:
            return obj.invoice.item
        return '--'
    view_item.short_description = 'item'

admin.site.register(Payment,PaymentList)

class BookList(SimpleHistoryAdmin):
    list_display = ('id','title','createdAt',)
    search_fields = ('title',)

admin.site.register(Book,BookList)

class PurchaseList(SimpleHistoryAdmin):
    list_display = ('id','user','createdAt',)
    list_filter = ('createdAt',)
    raw_id_fields = ('user',)
    search_fields = ('user__mobile',)
    autocomplete_fields = ('books',)

admin.site.register(Purchase,PurchaseList)