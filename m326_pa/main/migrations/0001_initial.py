# Generated by Django 4.1.1 on 2022-09-28 08:16

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='TopLevelCompetence',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('updatedAt', models.DateTimeField()),
                ('createdAt', models.DateTimeField(editable=False)),
            ],
            options={
                'verbose_name_plural': 'Top Level Competences',
            },
        ),
        migrations.CreateModel(
            name='MidLevelCompetence',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('updatedAt', models.DateTimeField()),
                ('createdAt', models.DateTimeField(editable=False)),
                ('parentCompetence', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='main.toplevelcompetence')),
            ],
            options={
                'verbose_name_plural': 'Mid Level Competences',
            },
        ),
        migrations.CreateModel(
            name='LowLevelCompetence',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('updatedAt', models.DateTimeField()),
                ('createdAt', models.DateTimeField(editable=False)),
                ('midlevelkompetenz', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='main.midlevelcompetence')),
            ],
            options={
                'verbose_name_plural': 'Low Level Competences',
            },
        ),
    ]