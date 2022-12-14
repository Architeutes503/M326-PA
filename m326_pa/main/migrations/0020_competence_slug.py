# Generated by Django 4.1.3 on 2022-12-14 07:35

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('main', '0019_alter_achievedcompetence_slug_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='competence',
            name='slug',
            field=models.SlugField(default=django.utils.timezone.now, max_length=200, unique=True),
            preserve_default=False,
        ),
    ]