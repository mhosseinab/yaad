from django.urls import path

from . import views

app_name = 'yaad'

urlpatterns = [
    path('slide/', views.Slides.as_view()),
    path('slide/<int:pk>/', views.Slides.as_view()),
    path('store/rows/', views.StoreRows.as_view()),
    path('store/rows/<int:pk>/', views.StoreRows.as_view()),


]