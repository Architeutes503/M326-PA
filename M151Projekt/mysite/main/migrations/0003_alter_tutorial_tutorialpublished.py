# Generated by Django 4.0.4 on 2022-06-16 13:04

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('main', '0002_alter_tutorial_tutorialpublished'),
    ]

    operations = [
        migrations.AlterField(
            model_name='tutorial',
            name='tutorialPublished',
            field=models.DateTimeField(default=datetime.datetime(2022, 6, 16, 15, 4, 13, 846762), verbose_name='date published'),
        ),
    ]