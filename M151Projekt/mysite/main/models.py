from django.db import models
from datetime import datetime


class TutorialCategory(models.Model):
    tutorialCategory = models.CharField(max_length=200)
    categorySummary = models.CharField(max_length=400)
    categorySlug = models.CharField(max_length=200, default=1)

    class Meta:
        verbose_name_plural = "Categories"

    def __str__(self):
        return self.tutorialCategory


class TutorialSeries(models.Model):
    tutorialSeries = models.CharField(max_length=200)
    tutorialCategory = models.ForeignKey(TutorialCategory, null=True, default=None, verbose_name="Category", on_delete=models.SET_DEFAULT)
    tutorialSeriesSummary = models.CharField(max_length=400)

    class Meta:
        verbose_name_plural = "Series"

    def __str__(self):
        return self.tutorialSeries



class Tutorial(models.Model):
    tutorialTitle = models.CharField(max_length=200)
    tutorialContent = models.TextField()
    tutorialPublished = models.DateTimeField("date published", default=datetime.now())
    tutorialSeries = models.ForeignKey(TutorialSeries, null=True, default=1, verbose_name="Series" ,on_delete=models.SET_DEFAULT)
    tutorialSlug = models.CharField(max_length=200, default=1)

    def __str__(self):
        return self.tutorialTitle