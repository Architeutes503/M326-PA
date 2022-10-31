from tabnanny import check
from xml.etree.ElementInclude import LimitedRecursiveIncludeError
from django.db import models
from django.utils import timezone



class CompetenceCategory(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(CompetenceCategory, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Competence Categories"

    def __str__(self):
        return self.name



class CompetenceLevel(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(CompetenceLevel, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Competence Levels"

    def __str__(self):
        return self.name



class Job(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(Job, self).save(*args, **kwargs)

    def __str__(self):
        return self.name



class Ressource(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    url = models.URLField(blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(Ressource, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Ressources"

    def __str__(self):
        return self.name



class Competence(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    ressources = models.ManyToManyField(Ressource, blank=True)
    competenceCategory = models.ForeignKey(CompetenceCategory, on_delete=models.CASCADE)
    competenceLevel = models.ForeignKey(CompetenceLevel, on_delete=models.SET_DEFAULT, default=1)
    job = models.ForeignKey(Job, on_delete=models.SET_NULL, null=True, blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(Competence, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Competences"
    
    def __str__(self):
        return self.name



class Teacher(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    job = models.ForeignKey(Job, on_delete=models.SET_NULL, null=True, blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(Teacher, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Teachers"
    
    def __str__(self):
        return self.name



class AvailableCompetence(models.Model):
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE)
    competence = models.ForeignKey(Competence, on_delete=models.CASCADE)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(AvailableCompetence, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Avilable Competences"

    def __str__(self):
        return f"{self.competence.name} - {self.teacher.name}"


class AchievedCompetence(models.Model):
    competence = models.ForeignKey(Competence, on_delete=models.CASCADE)
    achievedAt = models.DateTimeField(default=timezone.now)
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, null=True, blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(AchievedCompetence, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Achieved Competences"

    def __str__(self):
        return self.competence.name



class PlannedCompetences(models.Model):
    competence = models.ForeignKey(Competence, on_delete=models.CASCADE)
    plannedAt = models.DateTimeField(default=timezone.now)
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, null=True, blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(PlannedCompetences, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Planned Competences"

    def __str__(self):
        return self.competence.name



class CompetenceProfile(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    teacher = models.ForeignKey(Teacher, on_delete=models.SET_NULL, null=True, blank=True)
    competences = models.ManyToManyField(AvailableCompetence, blank=True)
    achievedCompetences = models.ManyToManyField(AchievedCompetence, blank=True)
    plannedCompetences = models.ManyToManyField(PlannedCompetences, blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs,):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(CompetenceProfile, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Competence Profiles"

    def __str__(self):
        return self.name