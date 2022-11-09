# Generated by Django 4.1.1 on 2022-11-03 13:39

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('main', '0012_alter_competence_competencecategory'),
    ]

    operations = [
        migrations.AlterField(
            model_name='achievedcompetence',
            name='competence',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='main.competence'),
        ),
        migrations.AlterField(
            model_name='availablecompetence',
            name='competence',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='main.competence'),
        ),
        migrations.AlterField(
            model_name='competenceprofile',
            name='teacher',
            field=models.ForeignKey(blank=True, default=1, null=True, on_delete=django.db.models.deletion.SET_NULL, to='main.teacher'),
        ),
        migrations.AlterField(
            model_name='plannedcompetences',
            name='competence',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='main.competence'),
        ),
    ]