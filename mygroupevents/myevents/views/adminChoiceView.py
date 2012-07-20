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
import unicodedata
def isValidForRecommendation(detail,location):
    yelp_query = {}
    if detail=="dining out":
        yelp_query["query"]="restaurant"   
        yelp_query["category"] = "restaurant"
    if detail =="drink":
        yelp_query['query'] = "bar"
        yelp_query["category"] = "nightlife"
    if location:
        yelp_query['location'] = location
 
    if yelp_query.has_key('query') and yelp_query.has_key('location'):
        return yelp_query
    else:  # must have both
        return {}    
             
def adminChoice(request, ehash, uhash):
    try:
        e = event.objects.get(ehash=ehash)
        if int(e.status) < EVENT_STATUS.HASDETAIL:
            data = {'error_msg': 'Please Provide The Detail First'}
            return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))
        if int(e.status) == EVENT_STATUS.VOTING:
            started = True
        else:
            started = False
            
        has_recommendation = False
        if isValidForRecommendation(e.detail,e.location):
            has_recommendation = True
                
        data = {'event':e, 'uhash':uhash, 'started':started,'has_recommendation':has_recommendation}
        return render_to_response('myevents/adminChoice.html', data, context_instance=RequestContext(request))
    except event.DoesNotExist:
        data = {'error_msg': 'event does not exist'}
        return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))
        
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

def addSearchChoice(request, ehash, uhash):
    if request.method == "POST":
        try:
            e = event.objects.get(ehash=ehash) 
            u = user.objects.get(uhash=uhash)
            name = request.POST.get('name', '')
            location = request.POST.get('location', '')
            notes = request.POST.get('notes', '')
            longtitude= request.POST.get('longtitude', '')
            latitude = request.POST.get('latitude','')
            url = request.POST.get('url','')
            rating = request.POST.get('rating','')
            reviewcount = request.POST.get('review_count','')
            query = request.POST.get('query','')
            what = ','.join(e.detail,e.what_other)
            zipcode = request.POST.get('zipcode','')
            
            try:
                ### if this particular user already added the entry before, update the entry 
                c = yelp.objects.get(name=name,location=location)
                c.rating = rating
                c.reviewcount = reviewcount 
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
    
def search_yelp(category,query,location,query_id):
    url_params={}
    if type(query) is unicode:
        url_params['term'] = unicodedata.normalize('NFKD', query).encode('ascii','ignore') 
    else:
        url_params['term'] = query
    url_params['location'] = location
    url_params['limit'] = "10"
    url_params['radius_filter'] = "3800"
    url_params['category_filter'] = category

    consumer_key = '4cJ1ZEMrBdiv4pFLj8AtDA'
    consumer_secret = '93EEwlZWhuzx2TrZzXWf847RFNE'
    token =  'CgZGSsOcAQ1nD6J8WIcKZi4up_mDflsw'
    token_secret =  'nwYBgTQb112p4j9F5_BqrP2iLlw'

    response = yelp_request("api.yelp.com", '/v2/search', url_params, consumer_key, consumer_secret,  token,  token_secret)
    
    t0 = time.time() 
    ys=[]
    # returned error
    if not response.has_key('businesses'):
        return  serializers.serialize('json', {}, indent=2, use_natural_keys=True)
    #parse yelp result
    for eachresult in response['businesses']:
        #must have a name
        if eachresult.has_key('name'):    
            name = eachresult['name'] 
            try:
                y = yelp.objects.get(name=name)
            except yelp.DoesNotExist:
                y = yelp.objects.create(name=name)
            if eachresult.has_key('id'):    
                y.yid = eachresult['id']
            if eachresult.has_key('image_url'):    
                y.image_url = eachresult['image_url']
            if eachresult.has_key('url'):    
                y.url = eachresult['url']
            if eachresult.has_key('mobile_url'):    
                y.mobile_url = eachresult['mobile_url']
            if eachresult.has_key('phone'):    
                y.phone = eachresult['phone']
            if eachresult.has_key('display_phone'):    
               y.display_phone = eachresult['display_phone']
            if eachresult.has_key('review_count'):    
                y.review_count = eachresult['review_count']
            if eachresult.has_key('categories'):         
                cls = []
                for c in eachresult['categories']:
                    cl = ','.join(c)
                    cls.append(cl)
                y.categories = ';'.join(cls)    
            if eachresult.has_key('rating'):    
                y.rating = eachresult['rating']    
            if eachresult.has_key('rating_img_url'):        
                y.rating_img_url = eachresult['rating_img_url']
            if eachresult.has_key('rating_img_url_small'):        
                y.rating_img_url_small= eachresult['rating_img_url_small'] 
            if eachresult.has_key('rating_img_url_large'):        
                y.rating_img_url_large = eachresult['rating_img_url_large']
            if eachresult.has_key('snippet_text'):        
                y.snippet_text = eachresult['snippet_text']
            if eachresult.has_key('snippet_img_url'):        
                y.snippet_img_url = eachresult['snippet_img_url']
           
            if eachresult.has_key('location'):
                local = eachresult['location']
                if local.has_key('address'):
                    y.location_address =  ','.join(local['address'])
                if local.has_key('city'):
                    y.location_city =  local['city']
                if local.has_key('coordinate'):
                    y.location_coordinate_latitude =  local['coordinate']['latitude']    
                    y.location_coordinate_longitude = local['coordinate']['longitude']    
                if local.has_key('country_code'):
                    y.location_country_code= local['country_code']    
                if local.has_key('display_address'):
                    y.location_display_address = ','.join(local['display_address'])
                if local.has_key('postal_code'):
                    y.location_postal_code =  local['postal_code']
                if local.has_key('geo_accuracy'):
                    y.location_geo_accuracy =  local['geo_accuracy']

        y.save()
        
        location=y.location_display_address
        try:
            newitem = item.objects.get(foreign_id=y.id,type=CHOICE_SOURCE.YELP)
        except item.DoesNotExist:
            #add image field
            newitem = item.objects.create(foreign_id=y.id, name=y.name, location=location, image=y.rating_img_url,notes=y.review_count,url=y.url,type=CHOICE_SOURCE.YELP)
        ys.append(newitem)
        # record this result results, store new item id or yelp id?????
        s = search_result.objects.create(query_id=query_id, yelp_result_id = newitem.id)
    print 'parse yelp result spent:', time.time()-t0  
    return  serializers.serialize('json', ys, indent=2, use_natural_keys=True)
    
# output: returns for suggestions
def getMyYelpChoices(request, ehash, uhash):
    if request.method == 'GET':
        u = user.objects.get(uhash=uhash) 
        e = event.objects.get(ehash=ehash)
        data = {}
        
        q = search_query.objects.create(term=e.detail,location=e.location, search_by_id = u.id, search_for_id=e.id)
        if e.location:
            if e.detail == "dining out":
                data = search_yelp('restaurants','restaurants',e.location,q.id)
            if e.detail == "drink":
                data = search_yelp('nightlife','bar',e.location,q.id)     
        return HttpResponse(data, mimetype='application/json')
    else:
        return render_to_response('myevents/error.html', {"message":"the request is not a get"}, context_instance=RequestContext(request))

# work in july 19. not finished.
# baseline recommendation algorithm
def getBaseRecommendation(request,ehash,uhash):
    if request.method == 'GET':
        u = user.objects.get(uhash=uhash)
        e = event.objects.get(ehash=ehash)
        data = {}
        # select all users of this event 
        eu = event_user.objects.filter(event_id=e.id)
        for row in eu:
            uid = row.user_id
            auser = user.objects.get(id=uid)
            # for a user, select past positive ratings 
            
        return HttpResponse(data, mimetype='application/json')
    else:
        return render_to_response('myevents/error.html', {"message":"the request is not a get"}, context_instance=RequestContext(request))

#select from search results
def getMyYelpSearchChoices(request,ehash,uhash):
    if request.method=="POST":
        u = user.objects.get(uhash=uhash)
        e = event.objects.get(ehash=ehash)
        data = {}
        query_term = request.POST.get('query')
        location = request.POST.get('location')
        
        #record query behavior, what if one user, for one event, searched twice??? record them but be careful when pulling out the results
        q = search_query.objects.create(term=query_term,location=location, search_by_id = u.id, search_for_id=e.id)
        if e.detail == 'dining out':
            data = search_yelp('restaurants',query_term,location, q.id)
        if e.detail == 'drink':
            data = search_yelp('nightlife',query_term,location, q.id)
        #for d in data:
        #    s = search_result.objects.create(query_id=q.id, yelp_result_id=d.id)
        #return to client, render search results 
        return HttpResponse(data, mimetype='application/json')
    else:
        return render_to_response('myevents/error.html', {"message":"the request is not a get"}, context_instance=RequestContext(request))
    
def editEventChoice(request, ehash, uhash):
    if request.method == "POST":
        manual_choices = request.POST.getlist('manual_choice_ids')
        #print manual_choices
        yelp_choices = request.POST.getlist('yelp_choice_ids')
        #print yelp_choices
        #past_choices = request.POST.getlist('history_choice_ids')
        try: 
            choice_objs = []
            e = event.objects.get(ehash=ehash)
            inviter = user.objects.get(uhash=uhash)
            for cid in manual_choices:
                try:
                    c = choice.objects.get(pickid=cid, pickfrom=CHOICE_SOURCE.MANUAL, pickby_id=inviter.id)
                    c.cnt += 1
                    c.save()
                except choice.DoesNotExist:
                    c = choice.objects.create(pickid=cid, pickfrom=CHOICE_SOURCE.MANUAL, pickby_id=inviter.id,cnt=1)                     
                try: # here is for wrong operation. shouldn't happen if not because of testing
                    ec = event_choice.objects.get(event_id= e.id,choice_id=c.id)
                except:
                    ec = event_choice.objects.create(event_id=e.id, choice_id=c.id)
                manual_c = manual.objects.get(id=cid)
                choice_objs.append(manual_c)
                
            for cid in yelp_choices:
                try:
                    c = choice.objects.get(pickid=cid, pickfrom=CHOICE_SOURCE.YELP, pickby_id=inviter.id)
                    c.cnt +=1
                    c.save()
                except choice.DoesNotExist:
                    c = choice.objects.create(pickid=cid, pickfrom=CHOICE_SOURCE.YELP, pickby_id=inviter.id,cnt=1)
                try: # here is for wrong operation. shouldn't happen if not because of testing
                    ec = event_choice.objects.get(event_id= e.id,choice_id=c.id)
                except:
                    ec = event_choice.objects.create(event_id=e.id, choice_id=c.id)
                # yelp data table is separated from item.
                yelp_c = item.objects.get(id=cid)
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
          

