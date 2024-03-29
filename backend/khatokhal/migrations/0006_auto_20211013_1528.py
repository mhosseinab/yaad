# Generated by Django 3.2.7 on 2021-10-13 13:28

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('khatokhal', '0005_historicalinvoice_historicalpayment_historicalpurchase_invoice_payment_purchase'),
    ]

    operations = [
        migrations.AlterField(
            model_name='historicalinvoice',
            name='status',
            field=models.PositiveSmallIntegerField(choices=[('0', 'pending'), ('1', 'success'), ('2', 'failed'), ('5', 'refunded')], default=0),
        ),
        migrations.AlterField(
            model_name='historicalpayment',
            name='status',
            field=models.PositiveSmallIntegerField(choices=[('0', 'initiated'), ('1', 'success'), ('2', 'failed'), ('3', 'unverified'), ('4', 'gateway error'), ('5', 'refunded')], default=0),
        ),
        migrations.AlterField(
            model_name='invoice',
            name='status',
            field=models.PositiveSmallIntegerField(choices=[('0', 'pending'), ('1', 'success'), ('2', 'failed'), ('5', 'refunded')], default=0),
        ),
        migrations.AlterField(
            model_name='payment',
            name='status',
            field=models.PositiveSmallIntegerField(choices=[('0', 'initiated'), ('1', 'success'), ('2', 'failed'), ('3', 'unverified'), ('4', 'gateway error'), ('5', 'refunded')], default=0),
        ),
        migrations.CreateModel(
            name='UserRate',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('rate', models.IntegerField()),
                ('createdAt', models.DateTimeField(auto_now_add=True)),
                ('updatedAt', models.DateTimeField(auto_now=True)),
                ('book', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='khatokhal.book')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='khatokhal_rates', to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='UserComment',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('text', models.TextField()),
                ('is_deleted', models.BooleanField(default=False)),
                ('createdAt', models.DateTimeField(auto_now_add=True)),
                ('updatedAt', models.DateTimeField(auto_now=True)),
                ('book', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='khatokhal.book')),
                ('parent', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to='khatokhal.usercomment')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='khatokhal_comments', to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
