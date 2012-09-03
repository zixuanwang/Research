from globalHeader import *
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader,RequestContext
from django.http import HttpResponse,HttpResponseRedirect
from myevents.models import * 
import datetime 
#from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from passlib.apps import custom_app_context as pwd_context

#get my events
def get_my_events(uid):
	my_events={}
	my_events['events_to_organize'] = []
	my_events['events_to_participate'] = []
	my_events['events_closed']=[]
	try:
		u=user.objects.get(id=uid)
		eu = event_user.objects.filter(user_id=u.id)
		if eu:
			for row in eu:
				eid = row.event_id
				role = row.role
				try:
					e = event.objects.get(id=eid)
					if int(e.status) < EVENT_STATUS.VOTING and role=="admin":
						my_events['events_to_organize'].append(e)
					if int(e.status) == EVENT_STATUS.VOTING:
						my_events['events_to_participate'].append(e)
					if int(e.status) == EVENT_STATUS.TERMINATED:
						my_events['events_closed'].append(e)
				except event.DoesNotExist:
					continue
	except user.DoesNotExist,event_user.DoesNotExist:
		pass
	#print my_events
	return my_events

def profile(request):
	if 'user_id' in request.session:
		uid = request.session['user_id']
		u = get_user_by_uid(uid)
		if u is not None: 
			myevents = get_my_events(uid)
			friends = get_my_friends(uid)
			data = {'user': u,'events_to_organize':myevents['events_to_organize'],'events_to_participate':myevents['events_to_participate'],'events_closed':myevents['events_closed'],'friends':friends}
			return render_to_response('myevents/profile.html',data,context_instance=RequestContext(request))
		else:
			return render_to_response('myevents/error.html',{'message':"wrong user id"},context_instance=RequestContext(request))
	else:
		return render_to_response('myevents/login.html',{},context_instance=RequestContext(request))

