# Generated by Django 3.2.7 on 2021-10-17 07:33

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('khatokhal', '0007_auto_20211013_1925'),
    ]

    operations = [
        migrations.AddField(
            model_name='usercomment',
            name='rate',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to='khatokhal.userrate'),
        ),
        migrations.AlterField(
            model_name='historicalinvoice',
            name='status',
            field=models.PositiveSmallIntegerField(choices=[(0, 'pending'), (1, 'success'), (2, 'failed'), (5, 'refunded')], default=0),
        ),
        migrations.AlterField(
            model_name='historicalpayment',
            name='status',
            field=models.PositiveSmallIntegerField(choices=[(0, 'initiated'), (1, 'success'), (2, 'failed'), (3, 'unverified'), (4, 'gateway error'), (5, 'refunded')], default=0),
        ),
        migrations.AlterField(
            model_name='invoice',
            name='status',
            field=models.PositiveSmallIntegerField(choices=[(0, 'pending'), (1, 'success'), (2, 'failed'), (5, 'refunded')], default=0),
        ),
        migrations.AlterField(
            model_name='payment',
            name='status',
            field=models.PositiveSmallIntegerField(choices=[(0, 'initiated'), (1, 'success'), (2, 'failed'), (3, 'unverified'), (4, 'gateway error'), (5, 'refunded')], default=0),
        ),
    ]
