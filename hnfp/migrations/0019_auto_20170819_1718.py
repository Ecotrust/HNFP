# -*- coding: utf-8 -*-
# Generated by Django 1.11.2 on 2017-08-20 00:18
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('hnfp', '0018_auto_20170816_1528'),
    ]

    operations = [
        migrations.AlterField(
            model_name='observation',
            name='number_of_observers',
            field=models.CharField(blank=True, default=1, max_length=100, null=True),
        ),
        migrations.AlterField(
            model_name='observation',
            name='observation_tally',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
    ]
