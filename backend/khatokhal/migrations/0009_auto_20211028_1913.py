# Generated by Django 3.2.7 on 2021-10-28 17:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('khatokhal', '0008_auto_20211017_0933'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='historicalstoresliderow',
            name='history_user',
        ),
        migrations.RemoveField(
            model_name='storebookrow',
            name='books',
        ),
        migrations.RemoveField(
            model_name='storebookrow',
            name='course',
        ),
        migrations.RemoveField(
            model_name='storebookrow',
            name='niveau',
        ),
        migrations.RemoveField(
            model_name='storebookrow',
            name='publisher',
        ),
        migrations.RemoveField(
            model_name='storesliderow',
            name='slides',
        ),
        migrations.RemoveField(
            model_name='historicalstorerow',
            name='content_id',
        ),
        migrations.RemoveField(
            model_name='historicalstorerow',
            name='content_type',
        ),
        migrations.RemoveField(
            model_name='storerow',
            name='content_id',
        ),
        migrations.RemoveField(
            model_name='storerow',
            name='content_type',
        ),
        migrations.AddField(
            model_name='historicalstorerow',
            name='item_type',
            field=models.CharField(choices=[('S', 'slide'), ('B', 'book')], default='B', max_length=1),
        ),
        migrations.AddField(
            model_name='historicalstorerow',
            name='items',
            field=models.JSONField(default=dict),
        ),
        migrations.AddField(
            model_name='historicalstorerow',
            name='show_title',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='historicalstorerow',
            name='title',
            field=models.CharField(blank=True, max_length=2048, null=True),
        ),
        migrations.AddField(
            model_name='storerow',
            name='item_type',
            field=models.CharField(choices=[('S', 'slide'), ('B', 'book')], default='B', max_length=1),
        ),
        migrations.AddField(
            model_name='storerow',
            name='items',
            field=models.JSONField(default=dict),
        ),
        migrations.AddField(
            model_name='storerow',
            name='show_title',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='storerow',
            name='title',
            field=models.CharField(blank=True, max_length=2048, null=True),
        ),
        migrations.DeleteModel(
            name='HistoricalStoreBookRow',
        ),
        migrations.DeleteModel(
            name='HistoricalStoreSlideRow',
        ),
        migrations.DeleteModel(
            name='StoreBookRow',
        ),
        migrations.DeleteModel(
            name='StoreSlideRow',
        ),
    ]
