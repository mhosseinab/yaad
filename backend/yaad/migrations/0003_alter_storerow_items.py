# Generated by Django 3.2.7 on 2021-12-28 10:49

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('yaad', '0002_auto_20211115_1615'),
    ]

    operations = [
        migrations.AlterField(
            model_name='storerow',
            name='items',
            field=models.JSONField(default=list),
        ),
    ]
