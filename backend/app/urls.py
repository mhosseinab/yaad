from django.conf import settings
from django.contrib import admin
from django.urls import path, include
from django.conf.urls.static import static

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('auth/', include('djoser.urls')),
    path('auth/', include('djoser.urls.authtoken')),
    path('auth/', include('djoser.urls.jwt')),
    path('admin/', admin.site.urls),
    
    path('accounts/', include('accounts.urls', namespace='accounts')),
    path('khatokhal/', include('khatokhal.urls', namespace='khatokhal')),
    path('yaad/', include('yaad.urls', namespace='yaad')),

    
    path('get/media/list/', views.GetMediaFileList.as_view(), name='get_media_list'),
    path('get/media/<int:pk>/', views.GetMedia, name='get_media'),
    path('set/media/', views.SetMedia.as_view(), name='set_media'),
    path('get/media/thumbnail/', views.GetMediaThumbnail.as_view(), name='get_media_thumb'),
]
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)