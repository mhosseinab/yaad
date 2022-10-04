from django.urls import path
from . import views

app_name = 'accounts'

urlpatterns = [
    path('get/token/', views.GetToken.as_view(), name='auth_get_token_url'),
    path('verify/token/', views.VerifyToken.as_view(), name='auth_verify_token_url'),
    path('profile/<int:pk>/', views.UpdateProfile.as_view()),
]