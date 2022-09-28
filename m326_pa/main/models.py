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




class Competence(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    competenceCategory = models.ForeignKey(CompetenceCategory, on_delete=models.CASCADE)
    competenceLevel = models.ForeignKey(CompetenceLevel, on_delete=models.SET_DEFAULT, default=1)
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
