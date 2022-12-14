"""kompetenzenapp URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.urls import path
from . import views


app_name = "main"


urlpatterns = [
    path("", views.Homepage, name="homepage"),
    path("register/", views.RegisterRequest, name="register"),
    path("logout/", views.LogoutRequest, name="logout"),
    path("login/", views.LoginRequest, name="login"),
    path("account/", views.AccountRequest, name="account"),
    path("competenceprofile/", views.CompetenceProfileRequest, name="competenceprofile"),
    path("removecompetence/<slug:slug>", views.DeleteCompetenceRequest, name="removecompetence"),
    path("competenceprofile/addachievedcompetence/<slug:slug>", views.AddAchievedCompetenceRequest, name="addachievedcompetence"),
    path("competenceprofile/addplannedcompetence/<slug:slug>", views.AddPlannedCompetenceRequest, name="addplannedcompetence"),
    path("competenceprofile/addressource/<slug:slug>", views.AddRessourceRequest, name="addressource"),
    path("competenceprofile/viewcompetence/<slug:slug>", views.ViewCompetenceRequest, name="viewcompetence"),
    path("removeressource/<slug:slug>/<slug:competenceSlug>", views.DeleteRessourceRequest, name="removeressource"),
]
