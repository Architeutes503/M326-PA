from email.policy import default
from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from .models import Job, Teacher, PlannedCompetences, Ressource, Competence
import datetime

class UserForm(UserCreationForm):
    email = forms.EmailField(required=True)
    inviteCode = forms.CharField(max_length=255, required=True)
    job = forms.ModelChoiceField(queryset=Job.objects.all(), required=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'job', 'password1', 'password2', 'inviteCode']


    def save(self, commit=True):  # sourcery skip: extract-method
        user = super(UserForm, self).save(commit=False)
        user.email = self.cleaned_data['email']
        job = self.cleaned_data['job']
        if job is None:
            job = Job.objects.get(id=1)
        if commit:
            user.save()
            teacher = Teacher.objects.create(user=user, job=job, name = user.username, description = None)
        return user



class AccountForm(forms.ModelForm):
    username = forms.CharField(required=False)
    email = forms.EmailField(required=False)
    firstName = forms.CharField(required=False)
    lastName = forms.CharField(required=False)
    class Meta:
        model = User
        fields = ['username', 'email', 'firstName', 'lastName']
    
    def save(self, commit=True):
        user = super(AccountForm, self).save(commit=False)
        currentUser = User.objects.get(id=self.instance.id)
        if(self.cleaned_data['username'] != ""):
            user.username = self.cleaned_data['username']
        else:
            user.username = currentUser.username
        if(self.cleaned_data['email'] != ""):
            user.email = self.cleaned_data['email']
        else:
            user.email = currentUser.email
        if(self.cleaned_data['firstName'] != ""):
            user.first_name = self.cleaned_data['firstName']
        else:
            user.first_name = currentUser.first_name
        if(self.cleaned_data['lastName'] != ""):
            user.last_name = self.cleaned_data['lastName']
        else:
            user.last_name = currentUser.last_name
        if commit:
            user.save()
        return user


class AddPlannedCompetenceForm(forms.ModelForm):
    day = forms.IntegerField(required=True)
    month = forms.IntegerField(required=True)
    year = forms.IntegerField(required=True)
    hour = forms.IntegerField(required=True)
    minute = forms.IntegerField(required=True)

    class Meta:
        model = PlannedCompetences
        fields = ['day', 'month', 'year', 'hour', 'minute']

    def save(self, competence, competenceProfile, commit=True):
        return PlannedCompetences.objects.create(competence=competence, competenceProfile=competenceProfile, plannedAt=datetime.datetime(self.cleaned_data['year'], self.cleaned_data['month'], self.cleaned_data['day'], self.cleaned_data['hour'], self.cleaned_data['minute']))