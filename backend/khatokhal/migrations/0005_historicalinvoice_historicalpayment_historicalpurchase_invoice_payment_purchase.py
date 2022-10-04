# Generated by Django 3.2.7 on 2021-10-10 17:23

from django.conf import settings
import django.core.validators
from django.db import migrations, models
import django.db.models.deletion
import simple_history.models
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('contenttypes', '0002_remove_content_type_name'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('khatokhal', '0004_auto_20211002_1928'),
    ]

    operations = [
        migrations.CreateModel(
            name='Invoice',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('uuid', models.UUIDField(db_index=True, default=uuid.uuid4, editable=False, unique=True)),
                ('item_id', models.PositiveIntegerField()),
                ('price', models.PositiveIntegerField()),
                ('discount', models.PositiveIntegerField(default=0)),
                ('status', models.PositiveSmallIntegerField(choices=[(0, 'pending'), (1, 'success'), (2, 'failed'), (5, 'refunded')], default=0)),
                ('createdAt', models.DateTimeField(auto_now_add=True)),
                ('updatedAt', models.DateTimeField(auto_now=True)),
                ('item_type', models.ForeignKey(limit_choices_to=models.Q(('app_label', 'khatokhal'), ('model', 'book')), on_delete=django.db.models.deletion.CASCADE, to='contenttypes.contenttype')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Purchase',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('createdAt', models.DateTimeField(auto_now_add=True)),
                ('updatedAt', models.DateTimeField(auto_now=True)),
                ('books', models.ManyToManyField(blank=True, to='khatokhal.Book')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Payment',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('uuid', models.UUIDField(db_index=True, default=uuid.uuid4, editable=False, unique=True)),
                ('gateway', models.CharField(max_length=150)),
                ('amount', models.IntegerField(validators=[django.core.validators.MinValueValidator(1000)])),
                ('recipt', models.CharField(blank=True, max_length=300, null=True)),
                ('tid', models.CharField(blank=True, max_length=300, null=True)),
                ('card', models.CharField(blank=True, default=None, max_length=50, null=True)),
                ('trace', models.CharField(blank=True, default=None, max_length=50, null=True)),
                ('status', models.PositiveSmallIntegerField(choices=[(0, 'initiated'), (1, 'success'), (2, 'failed'), (3, 'unverified'), (4, 'gateway error'), (5, 'refunded')], default=0)),
                ('note', models.TextField(blank=True, null=True)),
                ('createdAt', models.DateTimeField(auto_now_add=True)),
                ('updatedAt', models.DateTimeField(auto_now=True)),
                ('invoice', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='khatokhal.invoice')),
            ],
        ),
        migrations.CreateModel(
            name='HistoricalPurchase',
            fields=[
                ('id', models.BigIntegerField(auto_created=True, blank=True, db_index=True, verbose_name='ID')),
                ('createdAt', models.DateTimeField(blank=True, editable=False)),
                ('updatedAt', models.DateTimeField(blank=True, editable=False)),
                ('history_id', models.AutoField(primary_key=True, serialize=False)),
                ('history_date', models.DateTimeField()),
                ('history_change_reason', models.CharField(max_length=100, null=True)),
                ('history_type', models.CharField(choices=[('+', 'Created'), ('~', 'Changed'), ('-', 'Deleted')], max_length=1)),
                ('history_user', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='+', to=settings.AUTH_USER_MODEL)),
                ('user', models.ForeignKey(blank=True, db_constraint=False, null=True, on_delete=django.db.models.deletion.DO_NOTHING, related_name='+', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'historical purchase',
                'ordering': ('-history_date', '-history_id'),
                'get_latest_by': 'history_date',
            },
            bases=(simple_history.models.HistoricalChanges, models.Model),
        ),
        migrations.CreateModel(
            name='HistoricalPayment',
            fields=[
                ('id', models.BigIntegerField(auto_created=True, blank=True, db_index=True, verbose_name='ID')),
                ('uuid', models.UUIDField(db_index=True, default=uuid.uuid4, editable=False)),
                ('gateway', models.CharField(max_length=150)),
                ('amount', models.IntegerField(validators=[django.core.validators.MinValueValidator(1000)])),
                ('recipt', models.CharField(blank=True, max_length=300, null=True)),
                ('tid', models.CharField(blank=True, max_length=300, null=True)),
                ('card', models.CharField(blank=True, default=None, max_length=50, null=True)),
                ('trace', models.CharField(blank=True, default=None, max_length=50, null=True)),
                ('status', models.PositiveSmallIntegerField(choices=[(0, 'initiated'), (1, 'success'), (2, 'failed'), (3, 'unverified'), (4, 'gateway error'), (5, 'refunded')], default=0)),
                ('note', models.TextField(blank=True, null=True)),
                ('createdAt', models.DateTimeField(blank=True, editable=False)),
                ('updatedAt', models.DateTimeField(blank=True, editable=False)),
                ('history_id', models.AutoField(primary_key=True, serialize=False)),
                ('history_date', models.DateTimeField()),
                ('history_change_reason', models.CharField(max_length=100, null=True)),
                ('history_type', models.CharField(choices=[('+', 'Created'), ('~', 'Changed'), ('-', 'Deleted')], max_length=1)),
                ('history_user', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='+', to=settings.AUTH_USER_MODEL)),
                ('invoice', models.ForeignKey(blank=True, db_constraint=False, null=True, on_delete=django.db.models.deletion.DO_NOTHING, related_name='+', to='khatokhal.invoice')),
            ],
            options={
                'verbose_name': 'historical payment',
                'ordering': ('-history_date', '-history_id'),
                'get_latest_by': 'history_date',
            },
            bases=(simple_history.models.HistoricalChanges, models.Model),
        ),
        migrations.CreateModel(
            name='HistoricalInvoice',
            fields=[
                ('id', models.BigIntegerField(auto_created=True, blank=True, db_index=True, verbose_name='ID')),
                ('uuid', models.UUIDField(db_index=True, default=uuid.uuid4, editable=False)),
                ('item_id', models.PositiveIntegerField()),
                ('price', models.PositiveIntegerField()),
                ('discount', models.PositiveIntegerField(default=0)),
                ('status', models.PositiveSmallIntegerField(choices=[(0, 'pending'), (1, 'success'), (2, 'failed'), (5, 'refunded')], default=0)),
                ('createdAt', models.DateTimeField(blank=True, editable=False)),
                ('updatedAt', models.DateTimeField(blank=True, editable=False)),
                ('history_id', models.AutoField(primary_key=True, serialize=False)),
                ('history_date', models.DateTimeField()),
                ('history_change_reason', models.CharField(max_length=100, null=True)),
                ('history_type', models.CharField(choices=[('+', 'Created'), ('~', 'Changed'), ('-', 'Deleted')], max_length=1)),
                ('history_user', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='+', to=settings.AUTH_USER_MODEL)),
                ('item_type', models.ForeignKey(blank=True, db_constraint=False, limit_choices_to=models.Q(('app_label', 'khatokhal'), ('model', 'book')), null=True, on_delete=django.db.models.deletion.DO_NOTHING, related_name='+', to='contenttypes.contenttype')),
                ('user', models.ForeignKey(blank=True, db_constraint=False, null=True, on_delete=django.db.models.deletion.DO_NOTHING, related_name='+', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'historical invoice',
                'ordering': ('-history_date', '-history_id'),
                'get_latest_by': 'history_date',
            },
            bases=(simple_history.models.HistoricalChanges, models.Model),
        ),
    ]
