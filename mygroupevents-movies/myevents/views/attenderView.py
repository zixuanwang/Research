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
import MySQLdb 
import sys
import datetime
from django.utils.timezone import utc
import pytz

#DB operation, return the number of the vote for a choice in an event
#input: eid, cid,vote
def getChoiceVote(event_id,choice_id,vote):
    cnt = poll.objects.filter(event_id=event_id, choice_id=choice_id, vote=vote).count()
    return cnt

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
        
        local_tz = pytz.timezone('America/Dawson')
        loc_dt = e.closeDate.astimezone(local_tz)
        
        data = {'choices':choices,'user':u, 'posvotes':init_pos_votes,'negvotes':init_neg_votes,
                'myname':u.name,'event':e, 'isadmin':isadmin,'ehash':ehash,'uhash':uhash,'closeDate':loc_dt.strftime('%Y-%m-%d %H:%M:%S')}
        return render_to_response('myevents/attender.html',data,context_instance=RequestContext(request))
    except event.DoesNotExist, user.DoesNotExist:
        return render_to_response('myevents/error.html',{'message':"event or user doesnt exist"},context_instance=RequestContext(request))

# get a list of place objects associated to this event
def getEventChoices2(ehash):
    choice_objs =[]
    try:
        e = event.objects.get(ehash=ehash)
        cs = event_choice.objects.filter(event_id=e.id).distinct().values('choice')
        for cl in cs:
            cobj={}
            cid = cl['choice']
            cobj['id'] = cid
            c = choice.objects.get(id=cid)            
            if c:
                item_obj = item.objects.get(id=c.pickid)
                cobj["name"] = item_obj.name 
                cobj['location'] = item_obj.location
                cobj['image'] = item_obj.image   # this is always empty.
                cobj['notes'] = item_obj.notes
                cobj['url'] = item_obj.url
                choice_objs.append(cobj)
    except event.DoesNotExist:
        return choice_objs        
    return choice_objs

    
# get a list of place objects associated to this event
def getEventChoices(ehash):
    choice_objs =[]
    try:
        e = event.objects.get(ehash=ehash)
        cs = choice.objects.filter(event_id=e.id).distinct()
        for cl in cs:
            print cl.id,cl.schedule_id
            cobj={}
            sid = cl.schedule_id
            cobj['id'] = cl.id  # id should be choice id, not schedule id 
            
            #c = schedule.objects.get(id=cid)            
            conn = MySQLdb.connect(host = "localhost",user = "root", passwd = "fighting123", db = "mymovies")
            cursor = conn.cursor()
            query = "select m.title,t.name,t.street,t.city,t.state,t.postcode, s.showtimes from myevents_schedule s, myevents_theatre t,myevents_movie m where s.mov_id = m.mov_id and s.thid=t.thid and s.id="+str(sid)
            cursor.execute(query)
            rs = cursor.fetchall()
            print rs
            cursor.close()
            conn.close()
            for row in rs:
                cobj['movie_title'] = row[0]
                cobj['theatre_name'] = row[1]
                cobj['theatre_address'] = row[2]+' '+row[3]+' '+row[4]+' '+row[5]  
                cobj['showtimes'] = row[6]
                choice_objs.append(cobj)
    except event.DoesNotExist, choice.DoesNotExist:
        return choice_objs
        
    return choice_objs

#NOT USED ANYMORE
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

#NOT USED ANYMORE
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

# DB operation for setVote function
def setChoiceVote(event_id,user_id, choice_id,vote):
    try:
        ep = poll.objects.get(event_id=event_id,choice_id=choice_id,user_id=user_id)
        ep.vote = vote
        ep.save()
    except poll.DoesNotExist:
        ep = poll.objects.create(event_id=event_id, choice_id=choice_id,user_id=user_id, vote=vote)

#record all clicks into db
def setPollClick(event_id,user_id, choice_id,vote):
	ep = pollClick.objects.create(event_id=event_id,choice_id=choice_id,user_id=user_id, vote=vote)
	return ep

# set the vote of a choice
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
				setPollClick(e.id,u.id,int(c_id),num_vote)
				json = simplejson.dumps({"message":"Vote Success!"})
			else:
				json = simplejson.dumps({"message":"Wrong Vote value, not integer"})
			return HttpResponse(json, mimetype='application/json')
		except event.DoesNotExist or user.DoesNotExist:
			json = simplejson.dumps({"message":"Wrong Event or User !"})
			return HttpResponse(json, mimetype='application/json')
	else:
		return render_to_response('myEvents/error.html',{"message":"the request is not a post"},context_instance=RequestContext(request))  

# NEED Improve -> a new algorithm to pick the best one.
# return the most liked place, with the number of likes
# or the least hated place, with number of dislikes
def getResult(request,ehash,uhash):
    e = event.objects.get(ehash=ehash)
    # need to have values to have the group by effect
    rs = poll.objects.filter(event=e.id, vote=1).values('choice').annotate(num_votes=Count('choice')).order_by('-num_votes')
    if rs:  #if it's not empty
        print rs
        first_rs = rs[0]
        
        cid = first_rs['choice']
        print cid
        numlikes = first_rs['num_votes']
        
        try:
            c = choice.objects.get(id=cid)
        
            conn = MySQLdb.connect(host = "localhost",user = "root", passwd = "fighting123", db = "mymovies")
            cursor = conn.cursor()
            query = "select m.title,t.name,t.street,t.city,t.state,t.postcode, s.showtimes from myevents_schedule s, myevents_theatre t,myevents_movie m \
                where s.mov_id = m.mov_id and s.thid=t.thid and s.id="+str(c.schedule_id)
            cursor.execute(query)
            rss = cursor.fetchone()
            print rss
            place_detail = ', '.join(rss) 
            cursor.close()
            conn.close()
    
            json = simplejson.dumps({"place":place_detail,'numlikes':numlikes,'numdislikes':0})
        except choice.DoesNotExist:
            json = ''
    else:  #if no body vote on likes, this is not used yet
        rs = poll.objects.filter(event=e.id, vote=-1).values('choice').annotate(num_votes=Count('choice')).order_by('-num_votes') 
        if rs:
            first_rs = rs[0]
            cid = first_rs['choice']
            numdislikes = first_rs['num_votes']
            c = choice.objects.get(id=cid)

            conn = MySQLdb.connect(host = "localhost",user = "root", passwd = "fighting123", db = "mymovies")
            cursor = conn.cursor()
            query = "select m.title,t.name,t.street,t.city,t.state,t.postcode, s.showtimes from myevents_schedule s, myevents_theatre t,myevents_movie m where s.mov_id = m.mov_id and s.thid=t.thid and s.id="+str(c.schedule_id)
            cursor.execute(query)
            rss = cursor.fetchone()
            print rss
            dislikePl = ','.join(rss[0]) 
            cursor.close()
            conn.close()

            #dislikePl = least_bad_item.name + ' , '+least_bad_item.location + ' , '+least_bad_item.notes
            numdislikes = rs[0]['num_votes']
            json = simplejson.dumps({"place":dislikePl,'numlikes':0,'numdislikes':numdislikes})   
        else:
            json = simplejson.dumps({"place":"",'numlikes':0,'numdislikes':0})
    return HttpResponse(json,mimetype="application/json")

# close event, send out final notification 
# input eid, final choice
def terminateEvent(request,ehash,uhash):
    if request.method == "POST":    
        try:
            e = event.objects.get(ehash=ehash)
            finalChoice = request.POST.get('finalChoice')
            e.finalChoice = finalChoice
            e.closeDate = datetime.datetime.utcnow();
            e.save()
            if finalMessageMail(ehash,uhash):
                #seems this change doesnt work here. Why? because of the threads?
                e.status = EVENT_STATUS.TERMINATED  
                e.save()  
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

# return the place liked by me ,and disliked by me, for an event
# include : uid, eid
def getMyVotes(request,ehash,uhash):
#    if request.is_ajax():
    e = event.objects.get(ehash = ehash)
    u = user.objects.get(uhash = uhash)
    
    posids = poll.objects.filter(event_id=e.id,user_id=u.id,vote=1).values('choice')
    negids = poll.objects.filter(event_id=e.id,user_id=u.id,vote=-1).values('choice')
    likes = []
    dislikes = [] 
    for pl in posids:
        p = choice.objects.get(id = pl['choice'])
        likes.append(p.name)
    
    for pl in negids:
        p = choice.objects.get(id = pl['choice'])
        dislikes.append(p.name)
        
    json = simplejson.dumps({"likes":likes,'dislikes':dislikes})   
    return HttpResponse(json, mimetype='application/json')

# get the liked and disliked information for a choice
# input: choice_id and the event id 
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

# GET request: return all comments of the event
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
            return HttpResponse({'success':False},mimetype="application/json")
    else:
        return render_to_response('myevents/error.html',{"message":"the request is not a post"},context_instance=RequestContext(request))  
        
#a function to get the status of current event 
def fun_prepare_attender_data(eid,uid):
    try:
        e = event.objects.get(id=eid)
        u = user.objects.get(id=uid)
        e_u = event_user.objects.get(event_id=e.id, user_id=u.id)
    except event_user.DoesNotExist or event.DoesNotExist or user.DoesNotExist:
        data ={}
        return data
    
    if e_u.role == 'admin':
        isadmin = True
    else:
        isadmin = False
    choices = getEventChoices(e.ehash)
                #print choices
    init_pos_votes = {}
    init_neg_votes = {}
    for c in choices:
        init_pos_votes[c["id"]] = getChoiceVote(e.id,c["id"],1)
        init_neg_votes[c["id"]] = getChoiceVote(e.id,c["id"],-1)
        
    local_tz = pytz.timezone('America/Dawson')
    loc_dt = e.closeDate.astimezone(local_tz)
        
    data = {'choices':choices, 'user':u,'posvotes':init_pos_votes,'negvotes':init_neg_votes,
                'myname':u.name,'event':e, 'isadmin':isadmin,'ehash':e.ehash,'uhash':u.uhash,'closeDate':loc_dt.strftime('%Y-%m-%d %H:%M:%S')} 
    return data

def eventSummary(request,ehash,uhash):
    try:     
        e = event.objects.get(ehash=ehash)
        u = user.objects.get(uhash=uhash)
        data = fun_prepare_attender_data(e.id,u.id)
        return render_to_response('myevents/eventSummary.html',data,context_instance=RequestContext(request))               
    except event.DoesNotExist, user.DoesNotExist:
        return render_to_response('myevents/error.html',{"message":"the event or user does not exist"},context_instance=RequestContext(request))  

#for a given eid, return the list of attenders' emails
def db_get_all_attender_emails(eid):
    attender_emails =[]
    try:
        e = event.objects.get(id=eid)
        eu = event_user.objects.filter(event_id = eid, role='attender')
        if eu:
            for row in eu:
                u_instance = user.objects.get(id=row.user_id)
                attender_emails.append(u_instance.email)
    except event.DoesNotExist:
        print 'event is not existed!!  database corrupted?'
    
    return attender_emails 

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

def addMoreFriends(request,ehash,uhash):     
    if request.method=="POST":
        try:
            e = event.objects.get(ehash=ehash)
            u = user.objects.get(uhash=uhash)
            existingfriends_list  = db_get_all_attender_emails(e.id)
            #number_of_existing_friends = len(existingfriends_list)
            if e.status == EVENT_STATUS.TERMINATED:
                return render_to_response('myevents/error.html',{"message":"the event is closed, don't add friends"},context_instance=RequestContext(request))  

            friendEmails = request.POST.getlist("item[tags][]")    
            if friendEmails !=None: 
                #newfriends = ','.join(friendEmails)    
                for uemail in friendEmails:
                    uemail = str(uemail.strip())
                    if not uemail:  # if its empty
                        continue;
                    if uemail in existingfriends_list:
                        print "the user %s is already invited!!"%uemail
                    else:
                        print "adding a new user %s"%uemail
                        try:
                            attender = user.objects.get(email=uemail)
                            uhash = attender.uhash
                        except user.DoesNotExist:
                            attender = create_guest_user(uemail)
                        try:
                            ### avoid the case that the user is already inserted. 
                            eu = event_user.objects.get(event_id=e.id, user_id=attender.id, role="attender")
                        except event_user.DoesNotExist:
                            eu = event_user.objects.create(event_id=e.id, user_id=attender.id, role="attender")  #update event_user
                        #update the event friends list
                        existingfriends_list.append(uemail)
                        try:
                        ### update friendship table
                            f = friend.objects.get(u_id=u.id, v_id=attender.id)
                            f.cnt += 1
                            f.save()
                        except friend.DoesNotExist:
                            try:
                                f_opp = friend.objects.get(u_id=attender.id, v_id=u.id)
                                f_opp.cnt += 1
                                f_opp.save()
                            except friend.DoesNotExist:
                                f = friend.objects.create(u_id=u.id, v_id=attender.id, cnt=1)    
                        finally:
                            pass                    
                        ###SEND OUT invitation.
                        attenderMail(ehash, uhash, u.email, e.name, uemail)
                ####UPDATE event detail                
                #if number_of_existing_friends<len(existingfriends_list):    
                e.friends = ','.join(existingfriends_list)
                #e.friends = e.friends+','+newfriends
                e.save()   
            #END OF IF    
            return render_to_response('myevents/addFriendsSuccess.html',{'user':u},context_instance=RequestContext(request))               
        except event.DoesNotExist or user.DoesNotExist:
            return render_to_response('myevents/error.html',{"message":"invalid event or user"},context_instance=RequestContext(request))  
    else:
        return render_to_response('myevents/error.html',{"message":"the request is not a post"},context_instance=RequestContext(request)) 


#a function to get the status of current event 
def fun_prepare_attender_add_chioce_data(eid,uid):
    try:
        e = event.objects.get(id=eid)
        has_recommendation = False
        if isValidForRecommendation(e.eventDate,e.location):
            has_recommendation = True
        u = user.objects.get(id=uid)
        e_u = event_user.objects.get(event_id=e.id, user_id=u.id)
    except event_user.DoesNotExist or event.DoesNotExist or user.DoesNotExist:
        data ={}
        return data
    if e_u.role == 'admin':
        isadmin = True
    else:
        isadmin = False
    choices = getEventChoices(e.ehash)
                #print choices
    init_pos_votes = {}
    init_neg_votes = {}
    for c in choices:
        init_pos_votes[c["id"]] = getChoiceVote(e.id,c["id"],1)
        init_neg_votes[c["id"]] = getChoiceVote(e.id,c["id"],-1)
        
    local_tz = pytz.timezone('America/Dawson')
    loc_dt = e.closeDate.astimezone(local_tz)
        
    data = {'choices':choices, 'posvotes':init_pos_votes,'negvotes':init_neg_votes,
                'myname':u.name,'event':e, 'isadmin':isadmin,'ehash':e.ehash, 'uhash':u.uhash,'closeDate':loc_dt.strftime('%Y-%m-%d %H:%M:%S'),'has_recommendation':has_recommendation} 
    return data

# allow attender to propose choices
def attenderAddChoice(request, ehash, uhash):
    try:
        e = event.objects.get(ehash=ehash)
        u = user.objects.get(uhash=uhash)
        data = fun_prepare_attender_add_chioce_data(e.id,u.id)
        if int(e.status) < EVENT_STATUS.HASDETAIL or int(e.status)>EVENT_STATUS.VOTING:
            data = {'error_msg': 'It is not the right time to add more choices'}
            return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))
        else:
            return render_to_response('myevents/attenderAddChoice.html', data, context_instance=RequestContext(request))
    except event.DoesNotExist or user.DoesNotExist:
        data = {'error_msg': 'event or user does not exist'}
        return render_to_response('myevents/error.html', data, context_instance=RequestContext(request)) 
    
    
