# Create your views here.
from globalHeader import *
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader,RequestContext
from django.http import HttpResponse,HttpResponseRedirect
from myevents.models import * 
from myevents.forms  import IndexForm,AdminForm,VoteForm
from django.forms.fields import ChoiceField,MultipleChoiceField
from django.utils import simplejson

from django.db.models import Count
from django.core.context_processors import csrf
from django.views.decorators.csrf import csrf_exempt
import MySQLdb as mdb
import sys
import datetime
from django.utils.timezone import utc
import pytz
 
def attender(request,ehash,uhash):   
    try:
        e = event.objects.get(ehash=ehash)
        u = user.objects.get(uhash=uhash)
        
        e_u = event_user.objects.get(event_id=e.id, user_id=u.id)
        if e_u.role == 'admin':
            isadmin = True
        else:
            isadmin = False
        choices = getEventChoices(ehash)
        #print choices
        init_pos_votes = {}
        init_neg_votes = {}
        for c in choices:
            init_pos_votes[c["id"]] = getChoiceVote(e.id,c["id"],1)
            init_neg_votes[c["id"]] = getChoiceVote(e.id,c["id"],-1)
        data = {'choices':choices, 'posvotes':init_pos_votes,'negvotes':init_neg_votes,
                'myname':u.name,'event':e, 'isadmin':isadmin,'ehash':ehash,'uhash':uhash}
        return render_to_response('myevents/attender.html',data,context_instance=RequestContext(request))
    except event.DoesNotExist, user.DoesNotExist:
        return render_to_response('myevents/error.html',{'message':"event or user doesnt exist"},context_instance=RequestContext(request))

    
# get a list of place objects associated to this event
def getEventChoices(ehash):
    choice_objs =[]
    try:
        e = event.objects.get(ehash=ehash)
        cs = event_choice.objects.filter(event_id=e.id).distinct().values('choice')
        for cl in cs:
            cobj={}
            cid = cl['choice']
            cobj['id'] = cid
            c = choice.objects.get(id=cid)            
            if int(c.pickfrom) == CHOICE_SOURCE.MANUAL:
                manual_obj = manual.objects.get(id=c.pickid)#.values('name','location','notes')
                cobj["name"] = manual_obj.name 
                cobj['location'] = manual_obj.location
                cobj['image'] = manual_obj.image   # this is always empty.
                cobj['notes'] = manual_obj.notes
                cobj['url'] = ''
                choice_objs.append(cobj)
            if int(c.pickfrom) == CHOICE_SOURCE.YELP:
                yelp_obj = item.objects.get(id=c.pickid)#.values('name','location','notes')
                cobj["name"] = yelp_obj.name 
                cobj['location'] = yelp_obj.location
                cobj['image'] = yelp_obj.image 
                cobj['notes'] = yelp_obj.notes
                cobj['url'] = yelp_obj.url
                choice_objs.append(cobj)
            if int(c.pickfrom) == CHOICE_SOURCE.REC:
                yelp_obj = item.objects.get(id=c.pickid)#.values('name','location','notes')
                cobj["name"] = yelp_obj.name 
                cobj['location'] = yelp_obj.location
                cobj['image'] = yelp_obj.image 
                cobj['notes'] = yelp_obj.notes
                cobj['url'] = yelp_obj.url
                choice_objs.append(cobj)
    
    except event.DoesNotExist:
        return choice_objs
    #retrieve all distinct places for the event, return a list of dict{'place':plid, 'place':plid}
        
    return choice_objs

#######################NOT USED #DB operation
def updatePoll(ehash,uhash,places):
    place_names=[]
    for plid  in places:
        p = Place.objects.get(id=plid)
        place_names.append(p.name)
        e = Event.objects.get(ehash=ehash)
        u = User.objects.get(uhash=uhash)
        ep = Poll.objects.create(event=e,user=u,place=p,vote=VOTE_STATUS.YES)
    return place_names

#DB operation
def getChoiceVote(event_id,choice_id,vote):
    cnt = poll.objects.filter(event_id=event_id, choice_id=choice_id, vote=vote).count()
    return cnt

    
def getPosVote(request,ehash,uhash):
    if request.method == "GET":    
        message = {"cnt": ""}
        try:
            e = event.objects.get(ehash=ehash) 
            c_id = request.GET.get('choice_id')
            #print c_id
            cnt = getChoiceVote(e.id,int(c_id),1)
            message['cnt'] = str(cnt)
            
            json = simplejson.dumps(message)
            return  HttpResponse(json, mimetype='application/json')
        except event.DoesNotExist:
            return render_to_response('myEvents/error.html',{"There is no such event"},context_instance=RequestContext(request))
    return render_to_response('myEvents/error.html',{"should be a http GET"},context_instance=RequestContext(request))

def getNegVote(request,ehash,uhash):
    if request.method == "GET":    
        message = {"cnt": ""}
        try:
            e = event.objects.get(ehash=ehash) 
            c_id = request.GET.get('choice_id')
            cnt = getChoiceVote(e.id,int(c_id),-1)
            message['cnt'] = str(cnt)
            json = simplejson.dumps(message)
            return  HttpResponse(json, mimetype='application/json')
        except event.DoesNotExist:
            return render_to_response('myEvents/error.html',{"There is no such event"},context_instance=RequestContext(request))
    return render_to_response('myEvents/error.html',{"should be a http GET"},context_instance=RequestContext(request))

# DB operation
def setChoiceVote(event_id,user_id, choice_id,vote):
    try:
        ep = poll.objects.get(event_id=event_id,choice_id=choice_id,user_id=user_id)
        ep.vote = vote
        ep.save()
    except poll.DoesNotExist:
        ep = poll.objects.create(event_id=event_id, choice_id=choice_id,user_id=user_id, vote=vote)

def setVote(request,ehash,uhash):
    if request.method == "POST":    
        try:
            e = event.objects.get(ehash=ehash) 
            u = user.objects.get(uhash=uhash)
            c_id = request.POST.get('choice_id')
            vote  = request.POST.get('vote')
            #print c_id,vote
            if c_id.isdigit():  #'-1'.isdigit() = False
                num_vote = int(vote)
                setChoiceVote(e.id,u.id,int(c_id),num_vote)
                json = simplejson.dumps({"message":"Vote Success!"})
            else:
                json = simplejson.dumps({"message":"Wrong Vote value, not integer"})
            return HttpResponse(json, mimetype='application/json')
        except event.DoesNotExist or user.DoesNotExist:
            json = simplejson.dumps({"message":"Wrong Event or User !"})
            return HttpResponse(json, mimetype='application/json')
    else:
        return render_to_response('myEvents/error.html',{"message":"the request is not a post"},context_instance=RequestContext(request))  
    
def getResult(request,ehash,uhash):
    e = event.objects.get(ehash=ehash)
    # need to have values to have the group by effect
    rs = poll.objects.filter(event=e.id, vote=1).values('choice').annotate(num_votes=Count('choice')).order_by('-num_votes')
    if rs:  #if it's not empty
        first_rs = rs[0]
        cid = first_rs['choice']
        numlikes = first_rs['num_votes']
        c = choice.objects.get(id=cid)
        currPl=""
        if int(c.pickfrom) == CHOICE_SOURCE.MANUAL: 
            currPl = manual.objects.get(id=c.pickid).name
        if int(c.pickfrom) == CHOICE_SOURCE.YELP:
            currPl = yelp.objects.get(id=c.pickid).name
        json = simplejson.dumps({"place":currPl,'numlikes':numlikes,'numdislikes':0})
    else:  #if no body vote on likes, this is not used yet
        rs = poll.objects.filter(event=e.id, vote=-1).values('choice').annotate(num_votes=Count('choice')).order_by('-num_votes') 
         
        if rs:
            first_rs = rs[0]
            cid = first_rs['choice']
            numdislikes = first_rs['num_votes']
            c = choice.objects.get(id=cid)
            dislikePl=""
            if int(c.pickfrom) == CHOICE_SOURCE.MANUAL:
                dislikePl = manual.objects.get(id=c.pickid).name
            if int(c.pickfrom) == CHOICE_SOURCE.YELP:
                dislikePl = yelp.objects.get(id=c.pickid).name
             #dislikePl =rs[0]['name']
             #c = choice.objects.get(id=cid)
             #if c.pickfrom == CHOICE_SOURCE.MANUAL:
             #currPl = manual.objects.get(id=c.pickid).name
             #if c.pickfrom == CHOICE_SOURCE.YELP:
             #currPl = yelp.objects.get(id=c.pickid).name
            numdislikes = rs[0]['num_votes']
            json = simplejson.dumps({"place":dislikePl,'numlikes':0,'numdislikes':numdislikes})   
        else:
            json = simplejson.dumps({"place":"",'numlikes':0,'numdislikes':0})
    return HttpResponse(json,mimetype="application/json")
    
def terminateEvent(request,ehash,uhash):
    if request.method == "POST":    
        try:
            e = event.objects.get(ehash=ehash)
            finalChoice = request.POST.get('finalChoice')
            e.status = EVENT_STATUS.TERMINATED
            e.closeDate = datetime.datetime.utcnow();
            e.finalChoice = finalChoice
            e.save()
            if finalMessageMail(ehash):
                json = simplejson.dumps({'Terminated':True})   
            else:
                json = simplejson.dumps({'Terminated':False})   
        except event.DoesNotExist:
            json = simplejson.dumps({'Terminated':False})   
        return HttpResponse(json,mimetype="application/json")
    
def xhr_test(request,ehash,uhash):
    if request.is_ajax():
        message = "Hello AJAX"
    else:
        message = "Hello"
    return HttpResponse(message)

def getMyVotes(request,ehash,uhash):
#    if request.is_ajax():
    e = event.objects.get(ehash = ehash)
    u = user.objects.get(uhash = uhash)
    
    posids = Poll.objects.filter(event_id=e.id,user_id=u.id,vote=1).values('place')
    negids = Poll.objects.filter(event_id=e.id,user_id=u.id,vote=-1).values('place')
    likes = []
    dislikes = [] 
    for pl in posids:
        p = Place.objects.get(id = pl['place'])
        likes.append(p.name)
    
    for pl in negids:
        p = Place.objects.get(id = pl['place'])
        dislikes.append(p.name)
        
    json = simplejson.dumps({"likes":likes,'dislikes':dislikes})   
    return HttpResponse(json, mimetype='application/json')

def getVoteStats(request,ehash,uhash):
#    if request.is_ajax():
    e = event.objects.get(ehash = ehash)
    u = user.objects.get(uhash = uhash)
    id = request.GET.get('choice_id', '')

    posids = poll.objects.filter(event_id=e.id,choice_id =id,vote=1).values('user')
    negids = poll.objects.filter(event_id=e.id,choice_id=id,vote=-1).values('user')
    likes = []
    dislikes = [] 
    for pl in posids:
        p = user.objects.get(id = pl['user'])
        likes.append(p.name)
    
    for pl in negids:
        p = user.objects.get(id = pl['user'])
        dislikes.append(p.name)
        
    json = simplejson.dumps({"likes":likes,'dislikes':dislikes})   
    return HttpResponse(json, mimetype='application/json')

def getVoteDate(request,ehash,uhash):
    e = event.objects.get(ehash=ehash)
    #need the format of datetime object, otherwise json can't serialize it
    json = simplejson.dumps({"date":e.voteDate.isoformat()})
    return HttpResponse(json,mimetype="application/json")


def getAllComments(request,ehash,uhash):
    if request.method=='GET':
        try:
            e=event.objects.get(ehash=ehash)
            uc= comment.objects.filter(event_id=e.id).order_by('pub_date')
            comments = []
            for row in uc:
                uid = row.user_id
                uname = user.objects.get(id=uid).name
		local_tz = pytz.timezone('America/Dawson')
		loc_dt = row.pub_date.astimezone(local_tz)
                comments.append({'name':uname,'say':row.say,'date':loc_dt.strftime('%Y-%m-%d %H:%M:%S')})
            json = simplejson.dumps(comments)
        except event.DoesNotExist, user.DoesNotExist:
            json=simplejson.dumps({'success':'False'})
        return HttpResponse(json,mimetype="application/json")
    else:
         return render_to_response('myevents/error.html',{"message":"the request is not a get"},context_instance=RequestContext(request)) 
      
def writeComment(request,ehash,uhash):
    if request.method == "POST":    
        try:
            e=event.objects.get(ehash=ehash)
            u=user.objects.get(uhash=uhash)
            acomment = request.POST.get('acomment')
	    pub_date = datetime.datetime.utcnow().replace(tzinfo=utc)   
	    local_tz = pytz.timezone('America/Dawson')
	    loc_dt = pub_date.astimezone(local_tz)
	    c = comment.objects.create(event_id=e.id,user_id=u.id,say=acomment,pub_date=pub_date )
            response = simplejson.dumps({'name':u.name,'say':acomment,'date':loc_dt.strftime('%Y-%m-%d %H:%M:%S')})
            #response = simplejson.dumps({'name':u.name,'say':acomment,'date':c.pub_date.strftime('%Y-%m-%d %H:%M:%S')})
            return HttpResponse(response,mimetype="application/json")
        except event.DoesNotExist, user.DoesNotExist:
            return HttpResponse({'sucess':False},mimetype="application/json")
    else:
        return render_to_response('myevents/error.html',{"message":"the request is not a post"},context_instance=RequestContext(request))  
        
     
