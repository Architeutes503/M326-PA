from django.db import models
from django.utils import timezone

class TopLevelCompetence(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    updatedAt = models.DateTimeField()
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(TopLevelCompetence, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Top Level Competences"

    def __str__(self):
        return self.name





class MidLevelCompetence(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    parentCompetence = models.ForeignKey(TopLevelCompetence, on_delete=models.CASCADE)
    updatedAt = models.DateTimeField()
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(MidLevelCompetence, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Mid Level Competences"
    
    def __str__(self):
        return self.name




class LowLevelCompetence(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    midlevelkompetenz = models.ForeignKey(MidLevelCompetence, on_delete=models.CASCADE)
    updatedAt = models.DateTimeField()
    createdAt = models.DateTimeField(editable=False)

    def save(self, *args, **kwargs):
        ''' On save, update timestamps '''
        if not self.id:
            self.createdAt = timezone.now()
        self.updatedAt = timezone.now()
        return super(LowLevelCompetence, self).save(*args, **kwargs)

    class Meta:
        verbose_name_plural = "Low Level Competences"

    def __str__(self):
        return self.name