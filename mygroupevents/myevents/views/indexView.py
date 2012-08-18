from globalHeader import *
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader,RequestContext
from django.http import HttpResponse,HttpResponseRedirect
from myevents.models import * 
from myevents.forms  import IndexForm
import datetime 
from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User

def login(request):
    return render_to_response('myevents/login.html',{},context_instance=RequestContext(request))

def signup(request):
    return render_to_response('myevents/signup.html',{},context_instance=RequestContext(request))

def index(request):
    return render_to_response('myevents/index.html',{},context_instance=RequestContext(request))

def guest(request):
    return render_to_response('myevents/guest.html',{},context_instance=RequestContext(request))

def profile(request):
    if request.user.is_authenticated: 
        return render_to_response('myevents/profile.html',{'user':request.user},context_instance=RequestContext(request))
    else:
        return render_to_response('myevents/login.html',{},context_instance=RequestContext(request))

def userLogin(request):
    user_email = request.POST['user_email']
    password = request.POST['user_passwd']
    u = authenticate(email=user_email, password=password)
    if u is not None:
        if u.is_active:
            login(request, u)
            return render_to_response('myevents/profile.html',{'user':request.user},context_instance=RequestContext(request))
        else:
            return render_to_response('myevents/error.html',{'message':'invalid password or email'},context_instance=RequestContext(request))

    else:
        # Return an 'invalid login' error message.
        return render_to_response('myevents/error.html',{'message':'invalid login'},context_instance=RequestContext(request))

def checkUserExistence(request):
    if request.method=="GET":
        user_email = request.GET.get('user_email')
        try:
            u = User.objects.get(email=user_email)
            return HttpResponse({'is_existing':True}, mimetype='application/json')
        except User.DoesNotExist:
            return HttpResponse({'is_existing':False}, mimetype='application/json')
    else:
        return render_to_response('myevents/error.html',{'message':'the request type is wrong'},context_instance=RequestContext(request))

def createUser(request):
    if request.method == "POST":
        user_email = request.POST.get('user_email')
        user_name = request.POST.get('user_name')
        user_passwd = request.POST.get('user_passwd')
        try:
            u = User.objects.get(email = user_email)
            return render_to_response('myevents/error.html',{'message':'the email is already registered'},context_instance=RequestContext(request))
        except User.DoesNotExist:
            u = User.objects.create_user(user_name, user_email, user_passwd)
        return render_to_response('myevents/profile.html',{'user':u},context_instance=RequestContext(request))
    else:
        return render_to_response('myevents/error.html',{'message':'the request type is wrong'},context_instance=RequestContext(request))
            

def createEvent(request):
    if request.method == "POST":
        #form = IndexForm(request.POST)
        #for optimization
        t0 = time.time()
        #if form.is_valid():
        user_email = request.POST.get('user_email')
        event_name = request.POST.get('event_name')
        try:
            u = user.objects.get(email=user_email)
        except user.DoesNotExist:
            u_hash = make_uuid()    
            name = user_email.strip().split('@')[0]
            u = user.objects.create(email=user_email,uhash=u_hash,name=name)
        t1 = time.time()
        print 'Time for verifying the user:', t1-t0
        e_hash = make_uuid()
        event_date= datetime.datetime.now()
        # to record when the event closes. but the initial date is not good. 
        close_date = event_date + datetime.timedelta(days=7)
        e = event.objects.create(name=event_name,ehash=e_hash,inviter=u.email,eventDate=event_date,closeDate=close_date,status=EVENT_STATUS.INIT)
        #url = "http://www.mygroupevents.us:8889/myevents/" + e.ehash + "/" + u.uhash + "/admin/" 
        t2 = time.time()
        print 'Time for creating event:', t2-t1
        adminMail(e_hash,u.uhash,u.name,event_name,user_email)
        t3 = time.time()
        print 'Time for sending email:', t3-t2
            
        eu = event_user.objects.create(event_id = e.id, user_id=u.id,role="admin")
        print 'Time for create event_user relationship: ', time.time()-t3
        return render_to_response('myevents/thanks.html',{'email':user_email}, context_instance=RequestContext(request))
    else:
        return render_to_response('myevents/error.html',{'error_msg':'Request is not POST'},context_instance=RequestContext(request))

 
