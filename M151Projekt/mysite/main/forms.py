from email.policy import default
from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User

class UserForm(UserCreationForm):
    email = forms.EmailField(required=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password1', 'password2']

    def save(self, commit=True):
        user = super(UserForm, self).save(commit=False)
        user.email = self.cleaned_data['email']
        if commit:
            user.save()
        return user



class AccountForm(forms.ModelForm):
    username = forms.CharField(required=False)
    email = forms.EmailField(required=False)
    first_name = forms.CharField(required=False)
    last_name = forms.CharField(required=False)
    class Meta:
        model = User
        fields = ['username', 'email', 'first_name', 'last_name']
    
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
        if(self.cleaned_data['first_name'] != ""):
            user.first_name = self.cleaned_data['first_name']
        else:
            user.first_name = currentUser.first_name
        if(self.cleaned_data['last_name'] != ""):
            user.last_name = self.cleaned_data['last_name']
        else:
            user.last_name = currentUser.last_name
        if commit:
            user.save()
        return user