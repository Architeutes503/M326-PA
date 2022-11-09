from django.shortcuts import render
from django.http import HttpResponse

def index(request):
    return HttpResponse("This is the updated index page from the new dev server :)")
