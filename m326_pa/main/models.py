from tabnanny import check
from xml.etree.ElementInclude import LimitedRecursiveIncludeError
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User






def GenerateRandom():
        import random
        import string
        length = 10
        lettersAndDigits = string.ascii_letters + string.digits
        return ''.join(random.choice(lettersAndDigits) for _ in range(length))



class InviteCode(models.Model):
    code = models.CharField(max_length=255, unique=True, blank=True)
    used = models.BooleanField(default=False)
    usedBy = models.ForeignKey('auth.User', on_delete=models.CASCADE, null=True, blank=True)
    createdAt = models.DateTimeField(default=timezone.now)
    usedAt = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return self.code

    def save(self, *args, **kwargs):
        if not self.code:
            self.code = GenerateRandom()
        super(InviteCode, self).save(*args, **kwargs)

    def use(self, user):
        self.used = True
        self.usedBy = user
        self.usedAt = timezone.now()
        self.save()



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



class Competence(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    competenceCategory = models.ForeignKey(CompetenceCategory, on_delete=models.CASCADE, default=1)
    competenceLevel = models.ForeignKey(CompetenceLevel, on_delete=models.SET_DEFAULT, default=1)
    job = models.ForeignKey(Job, on_delete=models.SET_NULL, null=True, blank=True)
    slug = models.SlugField(max_length=200, unique=True, blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
            if not self.slug:
                self.slug = GenerateRandom()
        self.updatedAt = timezone.now()
        return super(Competence, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Competences"
    
    def __str__(self):
        return self.name



class Teacher(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    job = models.ForeignKey(Job, on_delete=models.SET_NULL, null=True, blank=True)
    user = models.OneToOneField(User, on_delete=models.CASCADE, null=True, blank=True)
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



class CompetenceProfile(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, null=True, blank=True, default=1)
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


class AchievedCompetence(models.Model):
    competence = models.ForeignKey(Competence, on_delete=models.CASCADE, default=1)
    achievedAt = models.DateTimeField(default=timezone.now)
    competenceProfile = models.ForeignKey(CompetenceProfile, on_delete=models.CASCADE, default=1)
    slug = models.SlugField(max_length=200, unique=True, blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
            if not self.slug:
                self.slug = GenerateRandom()
        self.updatedAt = timezone.now()
        return super(AchievedCompetence, self).save(*args, **kwargs)


    class Meta:
        verbose_name_plural = "Achieved Competences"

    def __str__(self):
        return self.competence.name



class PlannedCompetences(models.Model):
    competence = models.ForeignKey(Competence, on_delete=models.CASCADE, default=1)
    plannedAt = models.DateTimeField(default=timezone.now)
    competenceProfile = models.ForeignKey(CompetenceProfile, on_delete=models.CASCADE, default=1)
    slug = models.SlugField(max_length=200, unique=True, blank=True)
    updatedAt = models.DateTimeField(default=timezone.now)
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
            if not self.slug:
                self.slug = GenerateRandom()
        self.updatedAt = timezone.now()
        return super(PlannedCompetences, self).save(*args, **kwargs)


    class Meta:
        verbose_name_plural = "Planned Competences"

    def __str__(self):
        return self.competence.name



class Ressource(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    url = models.URLField(blank=True)
    competence = models.ForeignKey(Competence, on_delete=models.CASCADE)
    
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