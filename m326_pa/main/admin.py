from django.contrib import admin
from .models import CompetenceCategory, CompetenceLevel, Competence, Ressource

#also show id in admin
class CompetenceCategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'description', 'updatedAt', 'createdAt')
    list_display_links = ('id', 'name')
    search_fields = ('name', 'description')
    list_per_page = 25

class CompetenceLevelAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'description', 'updatedAt', 'createdAt')
    list_display_links = ('id', 'name')
    search_fields = ('name', 'description')
    list_per_page = 25

class CompetenceAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'description', 'competenceCategory', 'competenceLevel', 'updatedAt', 'createdAt')
    list_display_links = ('id', 'name')
    search_fields = ('name', 'description')
    list_per_page = 25


class RessourceAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'description', 'url', 'updatedAt', 'createdAt')
    list_display_links = ('id', 'name')
    search_fields = ('name', 'description')
    list_per_page = 25


admin.site.register(CompetenceCategory, CompetenceCategoryAdmin)
admin.site.register(CompetenceLevel, CompetenceLevelAdmin)
admin.site.register(Competence, CompetenceAdmin)
admin.site.register(Ressource, RessourceAdmin)