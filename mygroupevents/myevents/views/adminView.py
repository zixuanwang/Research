# Create your views here.
from globalHeader import *
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader, RequestContext
from django.http import HttpResponse, HttpResponseRedirect
from myevents.models import * 
from myevents.forms  import IndexForm, AdminFixedForm, VoteForm
from django.forms.fields import ChoiceField, MultipleChoiceField
from django.utils import simplejson
from django.core import serializers
import urllib2 
from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User

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

def admin(request):
    uid = request.session['user_id']
    eid = request.session['event_id']
    if uid and eid:
        u = get_user_by_uid(uid)
        if u is not None and u.is_authenticated(): 
            try:
                e = event.objects.get(id=eid)
                if int(e.status) == 1:
                    started = True
                else:
                    started = False
                myfriends = getMyFriends(u.uhash)
                data = {'event':e, 'uhash':u.uhash, 'started':started, 'myfriends':myfriends}
                return render_to_response('myevents/adminDetail.html', data, context_instance=RequestContext(request))
            except event.DoesNotExist:
                data = {'create EventError': 'an error is occured!'}
                return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))
        else:
            return render_to_response('myevents/error.html',{'error_msg':'invalid user. Please log in'},context_instance=RequestContext(request))
    else:
        return render_to_response('myevents/error.html',{'error_msg':'invalid user. Please log in'},context_instance=RequestContext(request))

   
def editEventAttr(request, ehash, uhash):
    updateResult = False
    if request.method == "POST":
        what = request.POST.get('what')
        eventDate = request.POST.get('when_date')
        eventTime = request.POST.get('when_time')
        friendEmails = request.POST.get("friendEmails")

        zipcode = request.POST.get('zipcode')
        city = request.POST.get('city')

        updateResult = updateEventFixedAttr(ehash, uhash, what, friendEmails, eventDate,eventTime, zipcode, city)
        if updateResult:
            e = event.objects.get(ehash=ehash)
            if e.status == 1:
                started = True
            else:
                started = False
            data = {'event': e, 'uhash':uhash, 'started':started }        
            return render_to_response('myevents/admin.html', data, context_instance=RequestContext(request))
        else:
            data = {'editEventError': 'an error is occured!'}
            return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))
    return render_to_response('myevents/admin.html', {}, context_instance=RequestContext(request))

def updateEventFixedAttr(ehash, uhash, what, friendEmails, eventDate,eventTime, zipcode, city):
    try:
        e = event.objects.get(ehash=ehash)
        u = user.objects.get(uhash=uhash)
        e.detail = what
        e.inviter = u.email
        e.eventDate = eventDate
        e.eventTime = eventTime
        e.zipcode = zipcode
        e.city = city
        e.friends = friendEmails
        e.save()
    except event.DoesNotExist or user, DoesNotExist:
        return False   ###ehash should be correct. 
    
    inviter = user.objects.get(uhash=uhash)
    if friendEmails !=None:
        for uemail in friendEmails:
            uemail = uemail.strip()
            try:
                attender = user.objects.get(email=uemail)
                uhash = attender.uhash
            except user.DoesNotExist:
                uhash = make_uuid()
                name = getNamebyEmail(uemail)
                attender = user.objects.create(email=uemail, uhash=uhash, name=name)
    
            try:
                ### avoid the case that the user is already inserted. 
                eu = event_user.objects.get(event_id=e.id, user_id=attender.id, role="attender")
            except event_user.DoesNotExist:
                eu = event_user.objects.create(event_id=e.id, user_id=attender.id, role="attender")  #update event_user
       
            try:
            ### update friendship table
                f = friend.objects.get(u_id=inviter.id, v_id=attender.id)
                f.cnt += 1
            except friend.DoesNotExist:
                try:
                    f_opp = friend.objects.get(u_id=attender.id, v_id=inviter.id)
                    f.cnt += 1
                except friend.DoesNotExist:
                    f = friend.objects.create(u_id=inviter.id, v_id=attender.id, cnt=1)    
        return True
    else:
        return False
        
def addManualChoice(request, ehash, uhash):
    if request.method == "POST":
        try:
            e = event.objects.get(ehash=ehash) 
            u = user.objects.get(uhash=uhash)
            name = request.POST.get('name', '')
            location = request.POST.get('location', '')
            notes = request.POST.get('notes', '')
            try:
                ### if this particular user already added the entry before, update the entry 
                c = manual.objects.get(name=name, addby_id=u.id)
                c.location = location
                c.notes = notes
                c.save()
            except manual.DoesNotExist:
                c = manual.objects.create(name=name, location=location, notes=notes, addby_id=u.id) 
            json = simplejson.dumps({"choice_id":c.id, "choice_name":c.name, "choice_location":c.location, "choice_notes":c.notes})
            return HttpResponse(json, mimetype='application/json')
        except event.DoesNotExist or user.DoesNotExist:
            json = simplejson.dumps({"choice":null})
            return HttpResponse(json, mimetype='application/json')
    else:
        return render_to_response('myevents/error.html', {"message":"the request is not a post"}, context_instance=RequestContext(request))
      
def getMyPastChoices(request, ehash, uhash):
    if request.method == 'GET':
        u = user.objects.get(uhash=uhash)
        cs = choice.objects.filter(addby_id=u.id)
        
        ### TBD: only pick the most frequent five.
        data = serializers.serialize('json', cs)        
        return HttpResponse(data, mimetype='application/json')
    else:
        return render_to_response('myevents/error.html', {"message":"the request is not a get"}, context_instance=RequestContext(request))
    
def search_yelp(query,zipcode):
    YWSID = 'edkozQ5nTFOPzADv2Oz2PA'
    zipcode = zipcode.replace(' ','%20')
    url = str('http://api.yelp.com/business_review_search?term='+query+'&location='+zipcode+'&ywsid='+YWSID)
    print url
    results = simplejson.loads(urllib2.urlopen(url).read())
    ys =[]
    #only return first 10 results
    for eachresult in results['businesses'][:10]:
        newresult = {}
        name = eachresult['name']
        location = eachresult['address1'] + ' ' + eachresult['address2'] +' ' + eachresult['address3'] + ' '+eachresult['city'] +' '+eachresult['state'] +' '+eachresult['zip'] 
        #phone = eachresult['phone']
        phone = eachresult['phone']
        url = eachresult['url']
        if eachresult.has_key('avg_rating'):
            rating = eachresult['avg_rating']
        else:
            rating = null
        try:  #if exist, update 
            y=yelp.objects.get(name=name)
            y.location=location
            y.notes = phone
            y.rating = rating
            y.where= zipcode
            y.what= query
            y.url = url
            y.save()
        except yelp.DoesNotExist:  # if not exist, create
             y = yelp.objects.create(name=name,location=location, notes=phone, rating=rating,where=zipcode,what=query, url=url)
        ys.append(y)
        
    return  serializers.serialize('json', ys, indent=2, use_natural_keys=True)
    
def getMyYelpChoices(request, ehash, uhash):
    if request.method == 'GET':
        u = user.objects.get(uhash=uhash) 
        e = event.objects.get(ehash=ehash)
         
        if e.detail:
            if "dining out" in e.detail:
                if e.zipcode:
                    data = search_yelp('restaurants', e.zipcode)
                elif e.city:
                    data = search_yelp('restaurants',e.city)
                else:  # todo 
                    data = {}
            else:
                 data = {}
        else:
            data = {}  # if the event detail is empty 
        return HttpResponse(data, mimetype='application/json')
    else:
        return render_to_response('myevents/error.html', {"message":"the request is not a get"}, context_instance=RequestContext(request))
    
def editEventChoice(request, ehash, uhash):
    if request.method == "POST":
        manual_choices = request.POST.getlist('manual_choice_ids')
        print manual_choices
        yelp_choices = request.POST.getlist('yelp_choice_ids')
        print yelp_choices
        #past_choices = request.POST.getlist('history_choice_ids')
 
        try: 
            choice_objs = []
            e = event.objects.get(ehash=ehash)
            inviter = user.objects.get(uhash=uhash)
            for cid in manual_choices:
                try:
                    c = choice.objects.get(pickid=cid, pickfrom=CHOICE_SOURCE.MANUAL, pickby_id=inviter.id)
                    c.cnt = c.cnt + 1;
                    c.save()
                except choice.DoesNotExist:
                    c = choice.objects.create(pickid=cid, pickfrom=CHOICE_SOURCE.MANUAL, pickby_id=inviter.id,cnt=1)                     
                ec = event_choice.objects.create(event_id=e.id, choice_id=c.id)
                manual_c = manual.objects.get(id=cid)
                choice_objs.append(manual_c)
                
            for cid in yelp_choices:
                try:
                    c = choice.objects.get(pickid=cid, pickfrom=CHOICE_SOURCE.YELP, pickby_id=inviter.id)
                    c.cnt = c.cnt+1;
                except choice.DoesNotExist:
                    c = choice.objects.create(pickid=cid, pickfrom=CHOICE_SOURCE.YELP, pickby_id=inviter.id,cnt=1)
                ec = event_choice.objects.create(event_id=e.id, choice_id=c.id)
                yelp_c = yelp.objects.get(id=cid)
                choice_objs.append(yelp_c)
                
            ### send a mail to inviter too, since he is the attender as well
            attenderMail(ehash, inviter.uhash, inviter.email, e.name, inviter.email)
            
            ### get all friends email
            attenders = e.friends.strip()
            all_attenders = attenders.split(',')

            ### send email to each attender 
            for each_attender in all_attenders:
                #remove space
                each_attender = each_attender.strip()    
                try:
                    attender = user.objects.get(email=each_attender)
                    attenderMail(ehash, attender.uhash, inviter.email, e.name, attender.email)
                except user.DoesNotExist:   #ignore the user which doesn't exist in the db
                    continue
                
            e.status = EVENT_STATUS.VOTING
            e.save()
            data = {'event': e, 'choices':choice_objs}        
            return render_to_response('myevents/success.html', data, context_instance=RequestContext(request))
        except event.DoesNotExist or user.DoesNotExist:
            return render_to_response('myevents/error.html', {"message":"event does not exist"}, context_instance=RequestContext(request))      
          

