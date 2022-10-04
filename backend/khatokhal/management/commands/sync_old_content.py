import logging
import re

from requests import get, post

from django.core.management.base import BaseCommand
from django.contrib.contenttypes.models import ContentType

from khatokhal import models

log = logging.getLogger(__name__)
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Linux; Android 11; SAMSUNG SM-G973U) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/14.2 Chrome/87.0.4280.141 Mobile Safari/537.36",
    "Accept": "*/*",
    "Accept-Language": "en-US,en;q=0.5",
    "Content-Type": "application/json",
    "Authorization": "my-auth-token",
    "Sec-Fetch-Dest": "empty",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Site": "cross-site",
    "referrer": "http://app.khatokhal.org/",
    "Cookie" : "_ga_EXM3KF602T=GS1.1.1634995256.12.0.1634995257.0; _ga=GA1.1.558832911.1608817287; _ga_WHMJG3NCM9=GS1.1.1634995258.4.0.1634995258.0; session_id=528f321747e8071cad5efb18c2aa9b541e38ff78",
}

CONTENT_TYPE = {
    'video':'V',
    'pic':'I',
    'text':'T',
}
EVENT_TYPE = {
    'foton',
    'message',
    'question',
}
class Command(BaseCommand):
    help = ''
    book_id = None
    book = None
    def add_arguments(self, parser):
        # Optional argument
        parser.add_argument('--id', type=int, action='store', help='book ID')

    def handle(self, *args, **options):
        bid = options.get('id')
        response = self.fetch_all()
        for timeline in response.get('result', []):
            for b in timeline.get('timeline_ids'):
                
                if bid and bid != b.get('id'):
                    continue

                print('---', b.get('id'), b.get('name'))
                book = self.save_book(b)
                # print(book)
                data = self.fetch_book(b.get('id'))
                chapter = self.save_chapter(data)

    def fetch_all(self):
        response = post("https://srv.khatokhal.org/web/dataset/call", 
            headers=HEADERS ,
            data="{\"params\":{\"model\":\"foton.api\",\"method\":\"getAllBooks\",\"args\":[[]]}}"
        )
        if response.status_code == 200:
            return response.json()
        return False

    def fetch_book(self, id: int):
        self.book_id = id
        response = post("https://srv.khatokhal.org/web/dataset/call", 
            headers=HEADERS ,
            data="{\"params\":{\"model\":\"foton.api\",\"method\":\"getTimelineData\",\"args\":[[]," + str(id) +",0]}}"
        )
        if response.status_code == 200:
            return response.json()
        return False
    
    def save_book(self, data:dict) -> models.Book:
        book, created = models.Book.objects.get_or_create(
            title = data.get('name'), defaults={
                'subtitle' : "",
                'author' : data.get('teacher_id')[1] if data.get('teacher_id') else "خط و خال",
                'about' : data.get('description'),
                'publisher' : models.Publisher.objects.get(pk=1),
                'course' : models.Course.objects.get_or_create(title=data.get('course_id')[1])[0],
                'niveau' : models.Niveau.objects.get(pk=1),
                'image' : self.copy_media(data.get('pic')),
                'video' : self.copy_media(data.get('video') if data.get('video') else None),
                'price' : 0,
                'discount' : 0
            }
        )
        
        self.book=book
        return book

    def save_chapter(self, data:dict):
        chapter = models.Chapter(title=self.book.title, book=self.book)
        
        for item in data.get('result', []):
            step = self.save_step(item)
            chapter.steps += step
        
        chapter.save()

    def save_step(self, data:dict):
        steps = []
        # print(data.get('eventType'))
        if data.get('eventType') in ['foton', 'message']:
            lesson = self.parse_lesson(data=data, isFoton=data.get('eventType')=='foton')
            if lesson != None:
                if isinstance(lesson, list):
                    for _lesson in lesson:
                        _step = models.Step(content_type=ContentType.objects.get_for_model(_lesson),content_id=_lesson.pk,content=_lesson)
                        _step.save()
                        steps.append(_step.pk)
                else:
                    _step = models.Step(content_type=ContentType.objects.get_for_model(lesson),content_id=lesson.pk,content=lesson)
                    _step.save()
                    steps.append(_step.pk)
        if data.get('eventType') == 'question':
            question = self.parse_question(data=data)
            if question != None:
                # print("question", question)
                _step = models.Step(content_type=ContentType.objects.get_for_model(question),content_id=question.pk,content=question)
                _step.save()
                steps.append(_step.pk)
        return steps
        
    def save_lesson(self, title:str, text:str, content_type:str,media:str):
        lesson = models.Lesson(
            book = self.book,
            title = title,
            text = text if text != 'ورق بزنید' else None,
            content_type = content_type,
        )

        if media:
            lesson.media = self.copy_media(media)
        # print(lesson)
        lesson.save()
        return lesson
        
    def parse_lesson(self, data:dict, isFoton:bool) -> models.Lesson:
        # eventType	"foton", foton_id
        title = data.get('title')
        _data = data.get('foton_id') if isFoton else data.get('message_id')
        text = _data.get('text') if _data.get('text') else None
        pics = _data.get('pic',[]) if isFoton else None
        media = _data.get('file_id') if _data.get('file_id') else None
        content_type =CONTENT_TYPE.get(_data.get('foton_type') if isFoton else _data.get('msgType'))
        if content_type == None:
            print(data)
            exit()
        print("L", content_type, pics, media)
        if isFoton and content_type == 'I' and len(pics)>0:
            lessons = []
            for pic in pics:
                lessons.append(self.save_lesson(title=title, text=text, media=pic, content_type=content_type))
            return lessons
        else:
            return self.save_lesson(title=title, text=text, media=media, content_type=content_type)
        
    def parse_question(self, data:dict) -> models.Lesson:
        # eventType	"question", question_id
        title = data.get('title')

        _data = data.get('question_id')

        text = _data.get('text') if _data.get('text') else None
        media = _data.get('file_id') if _data.get('file_id') else None
        content_type = CONTENT_TYPE.get(_data.get('question_type'))
        choice_count = _data.get('num_options',1)
        correct_answer = _data.get('answer','0')
        correct_answer = re.compile("option", re.IGNORECASE).sub('', correct_answer)

        print("Q", content_type, media)

        try:
            correct_answer = int(correct_answer)
        except:
            correct_answer = 0
        
        choices = []
        
        for i in range(1, int(choice_count)+1):
            choices.append({
                "text": str(i),
                "type": "T",
                "is_correct": i == correct_answer
            })
        answer = _data.get('answerCard_id')
        if not answer:
            answer = {
                "text": "",
                "content_type": "T"
            }
        else:
            answer = {
                "media": self.copy_media(answer.get('file_id')),
                "content_type": CONTENT_TYPE.get(answer.get('msgType'))
            }
        return self.save_question(title=title, text=text, media=media, content_type=content_type, choices=choices, answer=answer)

    def save_question(self, title:str, text:str, content_type:str, media:str,choices:list, answer:dict):
        question = models.Question(
            book = self.book,
            text = text if text != 'ورق بزنید' else None,
            content_type = content_type,
            answer=answer,
            answer_choices=choices,
        )

        if media:
            question.media = self.copy_media(media)
        question.save()

        return question
    
    def copy_media(self, src:str) -> str:
        if src:
            return src.replace('/foton/static', '/media/old')     
