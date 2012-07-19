# Create your views here.
from globalHeader import *
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader,RequestContext
from django.http import HttpResponse,HttpResponseRedirect
from myevents.models import * 
from myevents.forms  import IndexForm,AdminForm,VoteForm
from django.forms.fields import ChoiceField,MultipleChoiceField

from django.core.mail import EmailMessage
from django.core.context_processors import csrf
from django.views.decorators.csrf import csrf_exempt
import MySQLdb as mdb
import sys
 

EVENT_STATUS = enum(INIT=0,VOTING=1,TERMINATED=2)
VOTE_STATUS = enum(NO=0,YES=1,DONTKNOW=2)

def dictfetchall(cursor):
    "Returns all rows from a cursor as a dict"
    desc = cursor.description
    return [
        dict(zip([col[0] for col in desc], row))
        for row in cursor.fetchall()
    ]    
# get a list of place objects associated to this event
def getEventPlaces(ehash):
    restaurants=[]
    try:
        e = Event.objects.get(ehash=ehash)
    except Event.DoesnotExist:
        return restaurants
    #retrieve all distinct places for the event, return a list of dict{'place':plid, 'place':plid}
    places = Event_Place.objects.filter(event=e).distinct().values('place')

    for pl in places:
        rest = Place.objects.get(id=pl['place'])
        restaurants.append(rest)
    return restaurants


# get each place's vote of an event 
def getPlaceVote(places,ehash):
    from django.db import connection, transaction
    cursor = connection.cursor()
    e = Event.objects.get(ehash=ehash)
    query = "SELECT place_id, count(*) as cnt from myevents_poll where event_id = %s group by place_id" %str(e.id)
    cursor.execute(query)
    results = {}
    #for row in cursor.fetchall():
    for row in dictfetchall(cursor):
        #plid = int(row[0])     # 0-> place_id
        plid = int(row['place_id']) 
        p = Place.objects.get(id = plid)
        #results[p.name] = int(row[1])    # 1-> cnt
        results[p.name] = int(row['cnt'])
    return results

def getMyVote(ehash,uhash):
    e = Event.objects.get(ehash = ehash)
    u = User.objects.get(uhash = uhash)
    
    placeids = Poll.objects.filter(event=e,user=u).values('place')
    rests = []
    for pl in placeids:
        p = Place.objects.get(id = pl['place'])
        rests.append(p.name)
    return rests

#show the polling result of an event, ehash is necessary but uhash is not.
def pollResult(request,ehash,uhash=None):
    #if uhash exists. then show the user's result
    places = getEventPlaces(ehash)
    votes = getPlaceVote(places,ehash)
    data = {'votes':votes}
    #if provided uhash information
    if uhash:
        myvote = getMyVote(ehash,uhash)
        data ={'myvote':myvote, 'votes':votes}
    
    return render_to_response('myevents/result.html',data,context_instance=RequestContext(request))

    
    
