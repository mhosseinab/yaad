# Generated by Django 3.2.7 on 2021-11-15 15:15

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('books', '0003_auto_20211115_1615'),
        ('yaad', '0002_auto_20211115_1615'),
    ]

    operations = [
        migrations.DeleteModel(
            name='Book',
        ),
        migrations.DeleteModel(
            name='Chapter',
        ),
        migrations.DeleteModel(
            name='Course',
        ),
        migrations.DeleteModel(
            name='Lesson',
        ),
        migrations.DeleteModel(
            name='Media',
        ),
        migrations.DeleteModel(
            name='Niveau',
        ),
        migrations.DeleteModel(
            name='Publisher',
        ),
        migrations.DeleteModel(
            name='Question',
        ),
        migrations.DeleteModel(
            name='Section',
        ),
    ]
