from sre_parse import CATEGORIES
from urllib.request import HTTPRedirectHandler
from django.shortcuts import render, redirect
from django.http import HttpResponse
from .models import Tutorial, TutorialCategory, TutorialSeries
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from .forms import AccountForm, UserForm
from django.http import HttpResponseNotFound


def Homepage(request):
    return render(request,
                  'main/categories.html',
                  {"Categories": TutorialCategory.objects.all})


def RegisterRequest(request):
    if request.method == 'POST':
        form = UserForm(request.POST)
        if form.is_valid():
            user = form.save()
            username = form.cleaned_data.get('username')
            messages.success(request, f"New account created: {username}")
            login(request, user)
            messages.info(request, f"You are now logged in as {username}")
            return redirect("main:homepage")
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


def SingleSlug(request, singleSlug):
    if singleSlug == 'login':
        return redirect('main:login')
    elif singleSlug == 'register':
        return redirect('main:register')
    elif singleSlug == 'logout':
        return redirect('main:logout')
    elif singleSlug == 'account':
        return redirect('main:account')
    categories = [c.categorySlug for c in TutorialCategory.objects.all()]
    if singleSlug in categories:
        matchingSeries = TutorialSeries.objects.filter(
            tutorialCategory__categorySlug=singleSlug)
        seriesUrls = {}
        for m in matchingSeries.all():
            partOne = Tutorial.objects.filter(
                tutorialSeries__tutorialSeries=m.tutorialSeries).earliest("tutorialPublished")
            seriesUrls[m] = partOne.tutorialSlug
        return render(request, "main/category.html", {"partOnes": seriesUrls})

    tutorials = [t.tutorialSlug for t in Tutorial.objects.all()]
    if singleSlug in tutorials:
        thisTutorial = Tutorial.objects.get(tutorialSlug=singleSlug)
        tutorialsFromSeries = Tutorial.objects.filter(
            tutorialSeries__tutorialSeries=thisTutorial.tutorialSeries).order_by("tutorialPublished")
        thisTutorialIndex = list(tutorialsFromSeries).index(thisTutorial)
        return render(request, "main/tutorial.html", {"tutorial": thisTutorial, "tutorialsFromSeries": tutorialsFromSeries, "thisTutorialIndex": thisTutorialIndex})

    return HttpResponseNotFound("<h2>No Page Here</h2>")