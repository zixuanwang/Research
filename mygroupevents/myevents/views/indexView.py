from globalHeader import *
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader,RequestContext
from django.http import HttpResponse,HttpResponseRedirect
from myevents.models import * 
from myevents.forms  import IndexForm
import datetime 

def index(request):
    return render_to_response('myevents/index.html',{},context_instance=RequestContext(request))

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

 
