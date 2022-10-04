# Generated by Django 3.2.7 on 2021-10-17 07:33

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0003_userprofile'),
    ]

    operations = [
        migrations.AlterField(
            model_name='userprofile',
            name='field_of_study',
            field=models.PositiveSmallIntegerField(blank=True, choices=[(1, 'ریاضی'), (2, 'تجربی'), (3, 'انسانی'), (4, 'هنر'), (5, 'زبان')], null=True),
        ),
    ]