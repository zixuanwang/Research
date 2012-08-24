from globalHeader import *
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader,RequestContext
from django.http import HttpResponse,HttpResponseRedirect
from myevents.models import * 
import datetime 
from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from passlib.apps import custom_app_context as pwd_context

def login(request):
    return render_to_response('myevents/login.html',{},context_instance=RequestContext(request))

def signup(request):
    return render_to_response('myevents/signup.html',{},context_instance=RequestContext(request))

def index(request):
    return render_to_response('myevents/index.html',{},context_instance=RequestContext(request))

def guest(request):
    return render_to_response('myevents/guest.html',{},context_instance=RequestContext(request))

#only authenticate registered users
def verify_user(email,password):
    #salted_hash_password = pwd_context.encrypt(password)
    try:
        u = user.objects.get(email=email, is_registered=True)
        passwdhash = u.passwd
        print passwdhash
        ok =  pwd_context.verify(password, passwdhash)
        if ok:
            print 'OK'
            return u
        else:
            return None
    except user.DoesNotExist:
        return None

def loginUser(request):
    user_email = request.POST['user_email']
    password = request.POST['user_passwd']
    u = verify_user(user_email, password)
    if u is not None:
        if u.is_active:
            request.session['user_id'] = u.id
            return HttpResponseRedirect('../profile/')
        # return render_to_response('myevents/profile.html',{'user': u},context_instance=RequestContext(request))
        else:
            return render_to_response('myevents/error.html',{'message':'is not an active user'},context_instance=RequestContext(request))
    else:
        # Return an 'invalid login' error message.
        return render_to_response('myevents/error.html',{'message':'invalid login, wrong user_email or password'},context_instance=RequestContext(request))

def logout(request):
    try:
        del request.session['user_id']
    except KeyError:
        return render_to_response('myevents/error.html',{'message':'key error.'},context_instance=RequestContext(request))
    return render_to_response('myevents/logout.html',{},context_instance=RequestContext(request))

def checkRegisteredUserExistence(request):
    if request.method=="GET":
        user_email = request.GET.get('user_email')
        try:
            u = user.objects.get(email=user_email, is_registered=True)
            return HttpResponse({'is_existing':True}, mimetype='application/json')
        except User.DoesNotExist:
            return HttpResponse({'is_existing':False}, mimetype='application/json')
    else:
        return render_to_response('myevents/error.html',{'message':'the request type is wrong'},context_instance=RequestContext(request))

def createRegisterUser(request):
    if request.method == "POST":
        user_email = request.POST.get('user_email')
        user_name = request.POST.get('user_name')
        user_passwd = request.POST.get('user_passwd')
        salted_hash_password = pwd_context.encrypt(user_passwd)
        try:
            u = user.objects.get(email = user_email, is_registered=True,is_active=True)
            return render_to_response('myevents/registerSuccess.html',{'success':False,'message':'the email is already registered'},context_instance=RequestContext(request))
        except user.DoesNotExist:
            try: #if the user was guest, we only need to change the flag and set up the password
                u = user.objects.get(email=user_email,is_active=True)  #is_active is always true right now
                u.is_registered = True
                u.passwd = salted_hash_password
                u.save()
            except user.DoesNotExist:
                date_join= datetime.datetime.now()
                uhash =  make_uuid() 
                u = user.objects.create(name=user_name, email=user_email, passwd=salted_hash_password, uhash=uhash, is_registered=True, is_active=True,date_join=date_join)
            return render_to_response('myevents/registerSuccess.html',{'success':True,'message':u.name},context_instance=RequestContext(request))
    else:
        return render_to_response('myevents/error.html',{'message':'the request type is wrong'},context_instance=RequestContext(request))

def create_guest_user(email):
    try:
        u = user.objects.get(email=email)
        return u
    except user.DoesNotExist:
        user_name = getNamebyEmail(email)
        date_join= datetime.datetime.now()
        uhash=make_uuid()
        u = user.objects.create(name=user_name, email=email, passwd='', uhash=uhash,is_registered=False, is_active=True,date_join=date_join)
        return u

def createEvent(request):
    uid = request.session['user_id']
    if uid:
        u = get_user_by_uid(uid)
        if u is not None and u.is_authenticated(): 
            if request.method=="POST":
                event_name = request.POST.get('event_name')
                if event_name:
                    e_hash = make_uuid()
                    event_date= datetime.datetime.now()
                    # to record when the event closes. but the initial date is not good. 
                    close_date = event_date + datetime.timedelta(days=7)
                    e = event.objects.create(name=event_name,ehash=e_hash,inviter=u.email,eventDate=event_date,closeDate=close_date,status=EVENT_STATUS.INIT)
                    eu = event_user.objects.create(event_id = e.id, user_id=u.id,role="admin")
                    request.session['event_id'] = e.id
                    return HttpResponseRedirect('../'+e.ehash+'/adminDetail/')
            else:
                return render_to_response('myevents/error.html',{'error_msg':'Request is not POST'},context_instance=RequestContext(request))
        else:
            return render_to_response('myevents/error.html',{'error_msg':'invalid user. Please log in'},context_instance=RequestContext(request))
    else:
        return render_to_response('myevents/error.html',{'error_msg':'invalid user. Please Log In'},context_instance=RequestContext(request))


def createGuestEvent(request):
    if request.method == "POST":
        #form = IndexForm(request.POST)
        #for optimization
        t0 = time.time()
        #if form.is_valid():
        user_email = request.POST.get('user_email')
        event_name = request.POST.get('event_name')
        
       # try:
       #     u = user.objects.get(email=user_email)
       # except user.DoesNotExist:
       #     u_hash = make_uuid()    
       #     name = user_email.strip().split('@')[0]
       #     u = user.objects.create(email=user_email,uhash=u_hash,name=name)
        u = create_guest_user(user_email)
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

 
