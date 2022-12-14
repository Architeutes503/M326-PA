# Generated by Django 4.1.3 on 2022-12-14 16:32

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Competence',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('slug', models.SlugField(max_length=200, unique=True)),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
            ],
            options={
                'verbose_name_plural': 'Competences',
            },
        ),
        migrations.CreateModel(
            name='CompetenceCategory',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
            ],
            options={
                'verbose_name_plural': 'Competence Categories',
            },
        ),
        migrations.CreateModel(
            name='CompetenceLevel',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
            ],
            options={
                'verbose_name_plural': 'Competence Levels',
            },
        ),
        migrations.CreateModel(
            name='CompetenceProfile',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
            ],
            options={
                'verbose_name_plural': 'Competence Profiles',
            },
        ),
        migrations.CreateModel(
            name='Job',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
            ],
        ),
        migrations.CreateModel(
            name='Teacher',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True, null=True)),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
                ('job', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='main.job')),
                ('user', models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name_plural': 'Teachers',
            },
        ),
        migrations.CreateModel(
            name='Ressource',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('url', models.URLField(blank=True)),
                ('slug', models.SlugField(max_length=200, unique=True)),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
                ('competence', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='main.competence')),
                ('teacher', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='main.teacher')),
            ],
            options={
                'verbose_name_plural': 'Ressources',
            },
        ),
        migrations.CreateModel(
            name='PlannedCompetences',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('plannedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('slug', models.SlugField(blank=True, max_length=200, unique=True)),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
                ('competence', models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='main.competence')),
                ('competenceProfile', models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='main.competenceprofile')),
            ],
            options={
                'verbose_name_plural': 'Planned Competences',
            },
        ),
        migrations.CreateModel(
            name='InviteCode',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('code', models.CharField(blank=True, max_length=255, unique=True)),
                ('used', models.BooleanField(default=False)),
                ('createdAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('usedAt', models.DateTimeField(blank=True, null=True)),
                ('usedBy', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.AddField(
            model_name='competenceprofile',
            name='teacher',
            field=models.ForeignKey(blank=True, default=1, null=True, on_delete=django.db.models.deletion.CASCADE, to='main.teacher'),
        ),
        migrations.AddField(
            model_name='competence',
            name='competenceCategory',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='main.competencecategory'),
        ),
        migrations.AddField(
            model_name='competence',
            name='competenceLevel',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.SET_DEFAULT, to='main.competencelevel'),
        ),
        migrations.AddField(
            model_name='competence',
            name='job',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='main.job'),
        ),
        migrations.CreateModel(
            name='AvailableCompetence',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
                ('CompetenceProfile', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='main.competenceprofile')),
                ('competence', models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='main.competence')),
            ],
            options={
                'verbose_name_plural': 'Avilable Competences',
            },
        ),
        migrations.CreateModel(
            name='AchievedCompetence',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('achievedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('slug', models.SlugField(blank=True, max_length=200, unique=True)),
                ('updatedAt', models.DateTimeField(default=django.utils.timezone.now)),
                ('createdAt', models.DateTimeField(editable=False)),
                ('competence', models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='main.competence')),
                ('competenceProfile', models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='main.competenceprofile')),
            ],
            options={
                'verbose_name_plural': 'Achieved Competences',
            },
        ),
    ]
