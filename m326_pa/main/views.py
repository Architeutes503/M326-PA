from django.shortcuts import render
from django.http import HttpResponse
from urllib.request import HTTPRedirectHandler
from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from .forms import AccountForm, UserForm
from django.http import HttpResponseNotFound
from .models import InviteCode




def Homepage(request):
    return render(request,
                  'main/home.html')



def RegisterRequest(request):
    # sourcery skip: extract-method, remove-unnecessary-else
    if request.method == 'POST':
        form = UserForm(request.POST)
        if form.is_valid():
            codes = InviteCode.objects.filter(used=False)
            if form.cleaned_data['invite_code'] in codes.values_list('code', flat=True):
                user = form.save()
                inviteCode = InviteCode.objects.get(code=form.cleaned_data['invite_code'])
                inviteCode.use(user)
                username = form.cleaned_data.get('username')
                messages.success(request, f"New account created: {username}")
                login(request, user)
                messages.info(request, f"You are now logged in as {username}")
                return redirect("main:homepage")
            else:
                messages.error(request, "Invalid invite code")
        else:
            for msg in form.error_messages:
                messages.error(request, f"{msg}: {form.error_messages[msg]}")

    form = UserForm()
    return(render(request,
                  'main/register.html',
                  {'form': form}))




def AccountRequest(request):
    # check if user is logged in
    if request.user.is_authenticated:
        if request.method == 'POST':
            form = AccountForm(request.POST, instance=request.user)
            if form.is_valid():
                form.save()
                messages.success(request, "Account updated successfully")
                return redirect('main:homepage')

        form = AccountForm()
        return render(request, 'main/account.html', {'form': form})
    else:
        messages.error(request, "You are not logged in")
        return redirect("main:login")



def LogoutRequest(request):
    logout(request)
    messages.info(request, "Logged out successfully!")
    return redirect("main:homepage")




def LoginRequest(request):
    if request.method == 'POST':
        form = AuthenticationForm(request, request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(request, username=username, password=password)
            if user is not None:
                login(request, user)
                messages.info(request, f"You are now logged in as {username}")
                return redirect("main:homepage")
            else:
                messages.error(request, "Invalid username or password")
        else:
            messages.error(request, "Invalid username or password")

    form = AuthenticationForm()
    return(render(request,
                  'main/login.html',
                  {'form': form}))