# Generated by Django 4.1.2 on 2022-10-31 11:01

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('main', '0009_competenceprofile_availablecompetences_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='competenceprofile',
            name='availableCompetences',
        ),
        migrations.AlterField(
            model_name='competenceprofile',
            name='competences',
            field=models.ManyToManyField(blank=True, to='main.competence'),
        ),
    ]
