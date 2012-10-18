# Create your views here.
from globalHeader import *
from django.shortcuts import get_object_or_404, render_to_response,redirect
from django.template import Context, loader, RequestContext
from django.http import HttpResponse, HttpResponseRedirect
from myevents.models import * 
from myevents.forms  import IndexForm, AdminFixedForm, VoteForm
from django.forms.fields import ChoiceField, MultipleChoiceField
from django.utils import simplejson
from django.core import serializers
import urllib2 

from django.core.context_processors import csrf
from django.views.decorators.csrf import csrf_exempt
import MySQLdb as mdb
import sys
import datetime
 
def getMyFriends(uhash):
    friends = []
    try:
        u=user.objects.get(uhash=uhash)
        # order by cnt in descending order
        uv = friend.objects.filter(u_id=u.id).order_by('-cnt')
        suggest_number = 5
        i = 1
        for v in uv:
            if i > suggest_number:
                break
            i = i+1
            v_user = user.objects.get(id=v.v_id)
            friends.append(str(v_user.email))
    except user.DoesNotExist or friend.DoesNotExist:
        return False
    return friends 

def adminDetail(request,ehash):
    uid = request.session['user_id']
    if uid:
        u = get_user_by_uid(uid)
        if u is not None and u.is_authenticated(): 
            uhash = u.uhash
            try:
                e = event.objects.get(ehash=ehash)
                if int(e.status) == EVENT_STATUS.VOTING:
                    started = True
                else:
                    started = False
                myfriends = getMyFriends(uhash)
                data = {'event':e, 'user':u, 'uhash':uhash, 'started':started, 'myfriends':myfriends,'myemail':e.inviter}
                return render_to_response('myevents/adminDetail.html', data, context_instance=RequestContext(request))
            except event.DoesNotExist:
                data = {'error_msg': 'Event does not exist' }
                return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))
        else:
            return render_to_response('myevents/error.html',{'error_msg':'invalid user. Please log in'},context_instance=RequestContext(request))
    else:
        return render_to_response('myevents/error.html',{'error_msg':'invalid user. Please log in'},context_instance=RequestContext(request))

 
def adminDetail2(request, ehash, uhash):
    try:
        e = event.objects.get(ehash=ehash)
        if int(e.status) == EVENT_STATUS.VOTING:
            started = True
        else:
            started = False
        myfriends = getMyFriends(uhash)
        data = {'event':e, 'uhash':uhash, 'started':started, 'myfriends':','.join(myfriends),'myemail':e.inviter}
        return render_to_response('myevents/adminDetail.html', data, context_instance=RequestContext(request))
    except event.DoesNotExist:
        data = {'message': 'Event does not exist' }
        return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))

def fun_remove_extra_comma(friendEmails):
    correct_list = []
    f_list = friendEmails.split(',')
    for f in f_list:
        f = f.strip()
        if f:
            correct_list.append(f)
    return ','.join(correct_list)

def editEventAttrForm(request,ehash):
    uid= request.session['user_id']
    if not uid:
        return render_to_response('myevents/error.html', {'message':'invalid session'}, context_instance=RequestContext(request))
    try:
        u = user.objects.get(id=uid)
        uhash=u.uhash
        updateResult = False 
        if request.method == "POST":
            eventDate = request.POST.get('when_date')
            #print eventDate
            eventTime = request.POST.get('when_time')
            print 'Event Time is:%s'%eventTime
            e3 = request.POST.getlist("item[tags][]")
            print e3
            
            if len(e3)>=2:
                friendEmails = ','.join(e3)
            else:
                friendEmails=e3[0]         
            #friendEmailList = request.POST.get('emails')
        
            #friendEmails = fun_remove_extra_comma(friendEmailList)
            #print friendEmails    
            location = request.POST.get('location')
  
            updateResult = updateEventFixedAttr(ehash, uhash, friendEmails, eventDate,eventTime, location)
            if updateResult:
                e = event.objects.get(ehash=ehash)
                if e.status == 1:
                    started = True
                else:
                    started = False
                data = {'event': e, 'user':u,'uhash':uhash, 'started':started }  
                return HttpResponseRedirect('../adminChoice/')
            else:
                data = {'message': 'update Event detail failed'}
                return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))
            return render_to_response('myevents/adminDetail.html', {}, context_instance=RequestContext(request))
    except user.DoesNotExist:
        return render_to_response('myevents/error.html', {'message':'invalid user'}, context_instance=RequestContext(request))
        
def updateEventFixedAttr(ehash, uhash, friendEmails, eventDate,eventTime,location):
    try:
        e = event.objects.get(ehash=ehash)
        u = user.objects.get(uhash=uhash)
        e.inviter = u.email
        e.eventDate = eventDate
        e.eventTime = eventTime
        e.location = location
        e.friends = friendEmails
        e.status = EVENT_STATUS.HASDETAIL
        e.save()
    except event.DoesNotExist or user.DoesNotExist:
        return False   ###ehash should be correct. 
    
    inviter = user.objects.get(uhash=uhash)
    if friendEmails !=None: 
        #print friendEmails
        friendEs = friendEmails.split(',')
        for uemail in friendEs:
            uemail = str(uemail.strip())
            #print uemail
            try:
                attender = user.objects.get(email=uemail)
            except user.DoesNotExist:
                uhash = make_uuid()
                name = getNamebyEmail(uemail)
                date_join= datetime.datetime.now()
                attender = user.objects.create(email=uemail,passwd='', uhash=uhash, name=name, is_registered=False, is_active=True,date_join=date_join)
            #uhash = attender.uhash  #THIS IS NOT USED, YES?
            try:
                ### avoid the case that the user is already inserted. 
                eu = event_user.objects.get(event_id=e.id, user_id=attender.id, role="attender")
            except event_user.DoesNotExist:
                eu = event_user.objects.create(event_id=e.id, user_id=attender.id, role="attender")  #update event_user
       
            try:
            ### update friendship table
                f = friend.objects.get(u_id=inviter.id, v_id=attender.id)
                f.cnt += 1
                f.save()
            except friend.DoesNotExist:
                try:
                    f_opp = friend.objects.get(u_id=attender.id, v_id=inviter.id)
                    f_opp.cnt += 1
                    f_opp.save()
                except friend.DoesNotExist:
                    f = friend.objects.create(u_id=inviter.id, v_id=attender.id, cnt=1)    
        return True
    else:
        return False
        
 
