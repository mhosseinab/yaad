from django.db.models.query import Prefetch
# from django.db.models.query import QuerySet
from django.shortcuts import get_object_or_404
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from rest_framework import generics, mixins, status
from rest_framework.response import Response
from rest_framework.pagination import LimitOffsetPagination, PageNumberPagination
from rest_framework.permissions import IsAuthenticated, IsAdminUser, BasePermission, SAFE_METHODS

from .models import *
from .filters import *
from .serializers import *
from .payment import pay as payment_pay, verify as payment_verify

class ReadOnly(BasePermission):
    def has_permission(self, request, view):
        return request.method in SAFE_METHODS


class IsStaffUser(BasePermission):
    """
    Allows access only to admin users.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_staff

class IsStaffUser(BasePermission):
    """
    Allows access only to admin users.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_staff

class UserItemCountLimitForPurchase(LimitOffsetPagination):

    def get_limit(self, request):
        if request.user and request.user.is_authenticated:
            if request.user.is_staff:
                return 10_000
            bid = request.query_params.get('book')
            if bid:
                try:
                    book = Book.objects.get(pk=int(bid))
                    if book.price != 0 and book.price - book.discount > 0:
                        purchase, _ = Purchase.objects.get_or_create(user=request.user)
                        if book in purchase.books.all():
                            return 10_000
                    else:
                        return 10_000
                except Book.DoesNotExist:
                    pass
        return 1

class GenericView(mixins.ListModelMixin,
                  mixins.RetrieveModelMixin,
                  mixins.CreateModelMixin,
                  mixins.DestroyModelMixin,
                  mixins.UpdateModelMixin,
                  generics.GenericAPIView):
    permission_classes = [IsStaffUser | ReadOnly]
    def options(self, request, *args, **kwargs):
        if self.metadata_class is None:
            return self.http_method_not_allowed(request, *args, **kwargs)
        pk = kwargs.get('pk')
        if not pk:
            return Response(status=status.HTTP_204_NO_CONTENT)
        data = self.metadata_class().determine_metadata(request, self)
        return Response(data, status=status.HTTP_200_OK)

    def get(self, request, *args, **kwargs):
        pk = kwargs.get('pk')
        if pk:
            return self.retrieve(request, *args, **kwargs)
        return self.list(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)

    def put(self, request, *args, **kwargs):
        pk = kwargs.get('pk')
        if not pk:
            return self.http_method_not_allowed(request, *args, **kwargs)
        return self.update(request, *args, **kwargs)

    def patch(self, request, *args, **kwargs):
        pk = kwargs.get('pk')
        if not pk:
            return self.http_method_not_allowed(request, *args, **kwargs)
        return self.partial_update(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        pk = kwargs.get('pk')
        if not pk:
            return self.http_method_not_allowed(request, *args, **kwargs)
        return self.destroy(request, *args, **kwargs)


class Books(GenericView):
    serializer_class = BookSerializer
    filterset_class = BookFilter
    
    def get_queryset(self):
        is_yaad = '/yaad/' in self.request.path
        return Book.objects.filter(is_yaad=is_yaad).prefetch_related('course', 'niveau', 'publisher')


class Chapters(GenericView):
    queryset = Chapter.objects.all()
    serializer_class = ChapterSerializer
    filterset_class = ChapterFilter
    pagination_class = UserItemCountLimitForPurchase

class ChaptersList(mixins.ListModelMixin, generics.GenericAPIView):
    queryset = Chapter.objects.exclude(is_draft=True)
    filterset_class = ChapterFilter
    serializer_class = ChapterListSerializer
    # PageNumberPagination.page_size = 1000

    def get(self, request, *args, **kwargs):
        return self.list(request, *args, **kwargs)

class Sections(GenericView):
    queryset = Section.objects.all()
    serializer_class = SectionSerializer
    filterset_class = SectionFilter


class Lessons(GenericView):
    queryset = Lesson.objects.all()
    serializer_class = LessonSerializer
    filterset_class = LessonFilter


class Questions(GenericView):
    # permission_classes = [IsAdminUser | ReadOnly]
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer
    filterset_class = QuestionFilter


class Niveaus(GenericView):
    # permission_classes = [IsAdminUser | ReadOnly]
    queryset = Niveau.objects.all()
    serializer_class = NiveauSerializer
    filterset_class = NiveauFilter


class Courses(GenericView):
    # permission_classes = [IsAdminUser | ReadOnly]
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
    filterset_class = CourseFilter


class Publishers(GenericView):
    permission_classes = [IsAdminUser | ReadOnly]
    queryset = Publisher.objects.all().prefetch_related('logo')
    serializer_class = PublisherSerializer
    filterset_class = PublisherFilter


class StepItems(generics.GenericAPIView):
    queryset = Step.objects.all().prefetch_related('content')

    def get(self, request, format='json'):
        ids = [int(x) if x != '' else 0 for x in request.GET.get(
            'id', '0').split(',')]
        data = self.get_queryset().in_bulk(ids)
        for key in data:
            data[key] = StepSerializer(
                instance=data[key], context=self.get_serializer_context()).data
        return Response(data)


class Steps(GenericView):
    queryset = Step.objects.all().prefetch_related('content')
    serializer_class = StepSerializer
    filterset_class = StepFilter

    def create(self, request, *args, **kwargs):
        _content = None

        if request.data.get('type') == 'L':
            _content = LessonSerializer(data=request.data.get('content'), context=self.get_serializer_context())
        elif request.data.get('type') == 'Q':
            _content = QuestionSerializer(data=request.data.get('content'), context=self.get_serializer_context())
        elif request.data.get('type') == 'S':
            _content = SectionSerializer(data=request.data.get('content'), context=self.get_serializer_context())

        if not _content:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        
        _content.is_valid(raise_exception=True)
        print(_content.validated_data)
        _content.save()

        serializer = self.get_serializer(data={
            "id": request.data.get('id'),
            "content_id": _content.data.get('id'),
            "content_type": ContentType.objects.get_for_model(_content.instance).id
        })
        serializer.is_valid(raise_exception=True)
        serializer.save()
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

class Slides(GenericView):
    queryset = Slide.objects.all().prefetch_related('media',).order_by('row', '-pk')
    serializer_class = SlideSerializer
    filterset_class = SlideFilter

class StoreRows(GenericView):
    queryset = StoreRow.objects.all().order_by('row', '-pk')
    serializer_class = StoreRowSerializer


class BuyBook(generics.GenericAPIView):

    permission_classes = [IsAuthenticated]
    
    def get(self, request, *args, **kwargs):
        book = get_object_or_404(Book, pk=kwargs.get('id'))
        response = payment_pay(request.user, book)
        return Response(response, status=status.HTTP_200_OK if response.get('success') else status.HTTP_400_BAD_REQUEST)

class VerifyIDPay(generics.GenericAPIView):
    serializer_class = IDPayResponseSerializer
    
    def get(self, request, *args, **kwargs):
        
        serializer = self.serializer_class(data=request.GET, context={'request': request})
        
        if not serializer.is_valid(raise_exception=True):
            return Response(serializer.error_messages, status=status.HTTP_400_BAD_REQUEST)
        
        response = payment_verify(
            transaction_id = serializer.validated_data.get('id'), 
            payment_uid    = serializer.validated_data.get('order_id'),
        )
        
        return Response(response, status=status.HTTP_200_OK if response.get('success') else status.HTTP_400_BAD_REQUEST)

class BookRate(generics.GenericAPIView):
    serializer_class = BookRateSerializer
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data, context={'request': request})
        if not serializer.is_valid(raise_exception=True):
            return Response(serializer.error_messages, status=status.HTTP_400_BAD_REQUEST)

        rate = serializer.validated_data.get('rate')
        book = serializer.validated_data.get('book')
        user_rate, created = UserRate.objects.get_or_create(user=request.user, book=book, defaults={'rate': rate})
        
        if created:
            book.rate = (book.rate * book.rate_count * 1.0 + rate) / (book.rate_count * 1.0 + 1)
            book.rate_count += 1
        else:
            book.rate = ((book.rate * book.rate_count * 1.0) - user_rate.rate + rate) / (book.rate_count * 1.0)
            user_rate.rate = rate
            user_rate.save()

        book.save()

        return Response({'success': True, 'rate': book.rate, 'rate_count': book.rate_count } , status=status.HTTP_200_OK)
class BookComment(GenericView):
    queryset = UserComment.objects.exclude(is_deleted=True).prefetch_related('user','rate')
    serializer_class = UserCommentSerializer
    filterset_class = UserCommentFilter
    permission_classes = [IsAuthenticated | ReadOnly]
    
    @method_decorator(cache_page(60*5))
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    
    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data={**request.data,'rate':{'book':request.data.get('book'), 'rate': request.data.get('rate')}}, context={'request': request})
        if not serializer.is_valid(raise_exception=True):
            return Response(serializer.error_messages, status=status.HTTP_400_BAD_REQUEST)
        print("------>>>", serializer.validated_data)
        rate = serializer.validated_data.pop('rate')
        book = serializer.validated_data.get('book')
        print(book)
        user_rate, created = UserRate.objects.get_or_create(user=request.user, book=book, defaults={'rate': rate})
        
        if created:
            book.rate = (book.rate * book.rate_count * 1.0 + rate.get('rate')) / (book.rate_count * 1.0 + 1)
            book.rate_count += 1
        else:
            book.rate = ((book.rate * book.rate_count * 1.0) - user_rate.rate + rate.get('rate')) / (book.rate_count * 1.0)
            user_rate.rate = rate.get('rate')
            user_rate.save()
        print('saving .. book')
        book.save()
        serializer.save(user=request.user, rate=user_rate)

        return Response({'success': True} , status=status.HTTP_200_OK)

class UserPurchase(generics.GenericAPIView):
    queryset = Purchase.objects.all().prefetch_related('user','books')
    serializer_class = PurchaseSerializer
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        instanse = Purchase.objects.filter(user=request.user).prefetch_related('user','books').first()
        serializer = self.serializer_class(instance=instanse, context=self.get_serializer_context())
        return Response(serializer.data)
        


