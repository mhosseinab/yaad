# Generated by Django 3.2.7 on 2021-11-15 15:48

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('khatokhal', '0010_auto_20211109_1701'),
    ]

    operations = [
        migrations.AlterField(
            model_name='historicalstorerow',
            name='items',
            field=models.JSONField(default=list),
        ),
        migrations.AlterField(
            model_name='storerow',
            name='items',
            field=models.JSONField(default=list),
        ),
    ]
