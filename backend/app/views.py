import os
import ffmpeg
from base64 import urlsafe_b64decode
from urllib.parse import urlparse, unquote_plus
from hashlib import sha1
from random import randint
from django.http import JsonResponse
from django.shortcuts import redirect
from rest_framework import generics
from django.conf import settings
from rest_framework.permissions import BasePermission

from .models import *
from .serializers import *

class IsStaffUser(BasePermission):
    """
    Allows access only to admin users.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_staff

def index(request):
    if request.user and request.user.is_authenticated:
        return JsonResponse({'status':'ok', 'logged_in': True})
    return JsonResponse({'status':'ok'})


class GetMedia(generics.RetrieveAPIView):
    queryset = Media.objects.all()
    serializer_class = MediaSerializer
    
    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        print(serializer.data)
        return redirect(serializer.data.get('url'), permanent=True)

class SetMedia(generics.CreateAPIView):
    permission_classes = [IsStaffUser]
    serializer_class = MediaUploadSerializer

class GetMediaFileList(generics.RetrieveAPIView):
    permission_classes = [IsStaffUser]
    
    def retrieve(self, request, *args, **kwargs):
        return JsonResponse({'success':True, 'data': [path_to_dict(str(settings.MEDIA_ROOT))]})


def path_to_dict(path, depth=0):
    d = {'title': os.path.basename(path)}
    d['key'] = "{}-{}-{}".format(randint(1000000,9999999),depth, d.get('title'))
    if os.path.isdir(path):
        d['children'] = [path_to_dict(os.path.join(path,x), depth+1) for x in sorted(os.listdir(path))]
    else:
        d['isLeaf'] = True
    return d

class GetMediaThumbnail(generics.RetrieveAPIView):
    
    def retrieve(self, request, *args, **kwargs):
        
        try:
            url = urlsafe_b64decode(request.GET.get('url'))
            in_filename = Path(
                unquote_plus(
                    urlparse(url).path.decode("utf-8", "ignore").replace(settings.MEDIA_URL,'',1)
                ) 
            )
            if not (settings.MEDIA_ROOT / in_filename).exists():
                return JsonResponse({
                    'success': False, 
                    'err':'not exists', 
                    'file': str(settings.MEDIA_ROOT / in_filename)
                }, status=400)
        except Exception as e:
            print(e)
            return JsonResponse({'success': False, 'err':str(e)}, status=400)
        
        out_filename = 'thumbs/' + sha1(str(in_filename).encode("ascii", "ignore")).hexdigest() + '.jpg'
        
        if (settings.MEDIA_ROOT / out_filename).exists():
            return redirect(request.build_absolute_uri(settings.MEDIA_URL + out_filename), permanent=True)
        
        success, err = generate_thumbnail(
            str(settings.MEDIA_ROOT / in_filename), 
            str(settings.MEDIA_ROOT / out_filename)
        )

        if success:
            return redirect(request.build_absolute_uri(settings.MEDIA_URL + out_filename), permanent=True)
        
        return JsonResponse({'success':False, 'err': err}, status= 500)

def generate_thumbnail(in_filename, out_filename):

    try:
        probe = ffmpeg.probe(in_filename)
        time = 0.5 #float(probe['streams'][0]['duration']) // 2
        width = probe['streams'][0]['width']

        Path(settings.MEDIA_ROOT / 'thumbs').mkdir(parents=True, exist_ok=True)
        (
            ffmpeg
            .input(in_filename, ss=time)
            .filter('scale', width, -1)
            .output(out_filename, vframes=1)
            .overwrite_output()
            .run(capture_stdout=True, capture_stderr=True)
        )
        return True, None
    except ffmpeg.Error as e:
        print(e.stderr.decode())
        return False, e.stderr.decode()