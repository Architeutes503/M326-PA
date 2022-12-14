from django.shortcuts import render
from django.http import HttpResponse
from urllib.request import HTTPRedirectHandler
from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from .forms import AccountForm, UserForm, AddPlannedCompetenceForm
from django.http import HttpResponseNotFound
from .models import InviteCode, CompetenceProfile, Teacher, Competence, PlannedCompetences, AchievedCompetence, CompetenceLevel, CompetenceCategory




def RegisterRequest(request):
    # sourcery skip: extract-method, remove-unnecessary-else
    if request.method == 'POST':
        form = UserForm(request.POST)
        if form.is_valid():
            codes = InviteCode.objects.filter(used=False)
            if form.cleaned_data['inviteCode'] in codes.values_list('code', flat=True):
                user = form.save()
                inviteCode = InviteCode.objects.get(code=form.cleaned_data['inviteCode'])
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



def Homepage(request):
    if not request.user.is_authenticated:
        return redirect("main:login")
    if teacher := Teacher.objects.filter(user=request.user):
        if competenceProfile := CompetenceProfile.objects.filter(teacher=teacher[0]):
            return render(request,
                          'main/home.html',
                          {'CompetenceProfile': competenceProfile[0], 'Teacher': teacher[0]})
        #competence profile object
        competenceProfile = CompetenceProfile.objects.create(teacher=teacher[0], name=f"{teacher[0].user.username}'s competence profile", description=f"Competence profile of {teacher[0].user.username}")
        return render(request,
                        'main/home.html',
                        {'CompetenceProfile': competenceProfile, 'Teacher': teacher[0]})
    return render(request,
                'main/home.html')





def CompetenceProfileRequest(request):  # sourcery skip: extract-method
    if not request.user.is_authenticated:
        return redirect("main:login")
    if teacher := Teacher.objects.filter(user=request.user):
        if competenceProfile := CompetenceProfile.objects.filter(teacher=teacher[0]):
            job = teacher[0].job
            #all competences = all competences from db where job is not set or job is set to teacher's job
            allCompetences = Competence.objects.filter(job__isnull=True) | Competence.objects.filter(job=job)
            #get all planned competences from the db where competence profile is the competence profile of the teacher
            plannedCompetences = PlannedCompetences.objects.filter(competenceProfile=competenceProfile[0])
            #get all achieved competences from the db where competence profile is the competence profile of the teacher
            achievedCompetences = AchievedCompetence.objects.filter(competenceProfile=competenceProfile[0])
            #remove planned and achieved competences from all competences
            for plannedCompetence in plannedCompetences:
                allCompetences = allCompetences.exclude(id=plannedCompetence.competence.id)
            for achievedCompetence in achievedCompetences:
                allCompetences = allCompetences.exclude(id=achievedCompetence.competence.id)

            competenceCategories = CompetenceCategory.objects.filter(competence__in=allCompetences)
            competenceLevels = CompetenceLevel.objects.filter(competence__in=allCompetences)
            #get all categories for planned competences using the plannecCompetence.competence and the competenceCategory.competence
            plannedCompetenceCategories = CompetenceCategory.objects.filter(competence__in=plannedCompetences.values_list('competence', flat=True))
            plannedCompetenceLevels = CompetenceLevel.objects.filter(competence__in=plannedCompetences.values_list('competence', flat=True))
            achievedCompetenceCategories = CompetenceCategory.objects.filter(competence__in=achievedCompetences.values_list('competence', flat=True))
            achievedCompetenceLevels = CompetenceLevel.objects.filter(competence__in=achievedCompetences.values_list('competence', flat=True))
            return render(request,
                            'main/competenceprofile.html',
                            {'Competences': allCompetences, 'PlannedCompetences': plannedCompetences, 'AchievedCompetences': achievedCompetences, 'CompetenceCategories': competenceCategories, 'CompetenceLevels': competenceLevels, 'PlannedCompetenceCategories': plannedCompetenceCategories, 'PlannedCompetenceLevels': plannedCompetenceLevels, 'AchievedCompetenceCategories': achievedCompetenceCategories, 'AchievedCompetenceLevels': achievedCompetenceLevels})





#slug function that delets planned or achieved competence from the db
def DeleteCompetenceRequest(request, slug):
    if not request.user.is_authenticated:
        return redirect("main:login")
    if competence := PlannedCompetences.objects.filter(slug=slug):
        competence.delete()
        messages.success(request, "Planned competence deleted")
    elif competence := AchievedCompetence.objects.filter(slug=slug):
        competence.delete()
        messages.success(request, "Achieved competence deleted")
    else:
        messages.error(request, "Competence not found")
    return redirect("main:competenceprofile")

def AddPlannedCompetenceRequest(request, slug):
    if not request.user.is_authenticated:
        return redirect("main:login")
    if request.method == 'POST':
        if teacher := Teacher.objects.filter(user=request.user):
            if competenceProfile := CompetenceProfile.objects.filter(teacher=teacher[0]):
                if competence := Competence.objects.filter(slug=slug):
                    if not PlannedCompetences.objects.filter(competenceProfile=competenceProfile[0], competence=competence[0]):
                        form = AddPlannedCompetenceForm(request.POST)
                        if form.is_valid():
                            form.save(competence=competence[0], competenceProfile=competenceProfile[0])

                        messages.success(request, "Planned competence added")
                    else:
                        messages.error(request, "Competence already planned")
                else:
                    messages.error(request, "Competence not found")
            else:
                messages.error(request, "Competence profile not found")
        else:
            messages.error(request, "Teacher not found")
        return redirect("main:competenceprofile")

    form = AddPlannedCompetenceForm()
    return render(request, 'main/addcompetence.html', {'form': form})



def AddAchievedCompetenceRequest(request, slug):
    if not request.user.is_authenticated:
        return redirect("main:login")
    if teacher := Teacher.objects.filter(user=request.user):
        if competenceProfile := CompetenceProfile.objects.filter(teacher=teacher[0]):
            if competence := Competence.objects.filter(slug=slug):
                if not AchievedCompetence.objects.filter(competenceProfile=competenceProfile[0], competence=competence[0]):
                    achievedCompetence = AchievedCompetence.objects.create(competenceProfile=competenceProfile[0], competence=competence[0])
                    if plannedCompetence := PlannedCompetences.objects.filter(competenceProfile=competenceProfile[0], competence=competence[0]):
                        plannedCompetence.delete()
                    messages.success(request, "Achieved competence added")
                else:
                    messages.error(request, "Competence already added")
            else:
                messages.error(request, "Competence not found")
        else:
            messages.error(request, "Competence profile not found")
    else:
        messages.error(request, "Teacher not found")
    return redirect("main:competenceprofile")