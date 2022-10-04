from time       import time
from hashlib    import sha1
from datetime   import date
from pathlib    import Path

from django.db import models


def generate_filename(instance, filename):
  today = date.today()
  p = Path(filename)
  filename , ext = p.stem , p.suffix
  return Path('uploads', today.strftime("%Y/%m"), '{}{}'.format(sha1((str(time()) + filename).encode("ascii", "ignore")).hexdigest() , ext))

class Media(models.Model):
  title = models.CharField(max_length=1024, null=True, blank=True)
  file = models.FileField(upload_to=generate_filename)
  meta= models.JSONField(default=dict, null=True, blank=True)
  def __str__(self):
    return self.title or self.file.name or "no-title"
