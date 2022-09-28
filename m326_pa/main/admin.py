from django.contrib import admin
from .models import TopLevelCompetence, MidLevelCompetence, LowLevelCompetence

admin.site.register(TopLevelCompetence)
admin.site.register(MidLevelCompetence)
admin.site.register(LowLevelCompetence)