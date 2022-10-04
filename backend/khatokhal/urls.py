from django.urls import path

from . import views

app_name = 'khatokhal'

urlpatterns = [
    path('book/', views.Books.as_view()),
    path('book/<int:pk>/', views.Books.as_view()),
    path('book/yaad/', views.Books.as_view()),
    path('book/yaad/<int:pk>/', views.Books.as_view()),
    path('chapter/', views.Chapters.as_view()),
    path('chapter/list/', views.ChaptersList.as_view()),
    path('chapter/<int:pk>/', views.Chapters.as_view()),
    path('section/', views.Sections.as_view()),
    path('section/<int:pk>/', views.Sections.as_view()),
    path('lesson/', views.Lessons.as_view()),
    path('lesson/<int:pk>/', views.Lessons.as_view()),
    path('question/', views.Questions.as_view()),
    path('question/<int:pk>/', views.Questions.as_view()),
    path('course/', views.Courses.as_view()),
    path('course/<int:pk>/', views.Courses.as_view()),
    path('niveau/', views.Niveaus.as_view()),
    path('niveau/<int:pk>/', views.Niveaus.as_view()),
    path('publisher/', views.Publishers.as_view()),
    path('publisher/<int:pk>/', views.Publishers.as_view()),
    path('slide/', views.Slides.as_view()),
    path('slide/<int:pk>/', views.Slides.as_view()),
    path('step/', views.Steps.as_view()),
    path('step/<int:pk>/', views.Steps.as_view()),
    path('step/items/', views.StepItems.as_view()),
    path('store/rows/', views.StoreRows.as_view()),
    path('store/rows/<int:pk>/', views.StoreRows.as_view()),


    path('book/rate/', views.BookRate.as_view()),
    path('book/comment/', views.BookComment.as_view()),
    path('book/comment/<int:pk>/', views.BookComment.as_view()),

    path('payment/callback/idpay/', views.VerifyIDPay.as_view(), name='idpay_callback'),
    path('buy/book/<int:id>/', views.BuyBook.as_view()),
    path('purchases/', views.UserPurchase.as_view()),
    path('purchases/yaad/', views.UserPurchase.as_view()),


]