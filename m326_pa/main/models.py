from django.db import models
from datetime import datetime

class TopLevelCompetence(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    
    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = "Top Level Competences"





class MidLevelCompetence(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    parentCompetence = models.ForeignKey(TopLevelCompetence, on_delete=models.CASCADE)
    
    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = "Mid Level Competences"





class LowLevelCompetence(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    midlevelkompetenz = models.ForeignKey(MidLevelCompetence, on_delete=models.CASCADE)
    
    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = "Low Level Competences"