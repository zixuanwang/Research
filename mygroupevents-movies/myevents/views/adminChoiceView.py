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
import MySQLdb

def adminChoice(request, ehash):
	if 'user_id' not in request.session:
		return render_to_response('myevents/error.html', {'message':'This session is expired'}, context_instance=RequestContext(request))
	else:
		uid = request.session['user_id']
		u = get_user_by_uid(uid)
		if u is not None and u.is_authenticated(): 
			try:
				e = event.objects.get(ehash=ehash)
				if int(e.status) < EVENT_STATUS.HASDETAIL:
					data = {'message': 'Please Provide Event Detail First'}
					return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))
				if int(e.status) == EVENT_STATUS.VOTING:
					started = True
				else:
					started = False
			
				has_recommendation = False
				if isValidForRecommendation(e.eventDate,e.location):
					has_recommendation = True
					
				print has_recommendation
				data = {'event':e, 'user':u,'uhash':u.uhash, 'started':started,'has_recommendation':has_recommendation}
				return render_to_response('myevents/adminChoice.html', data, context_instance=RequestContext(request))
			except event.DoesNotExist:
				data = {'message': 'event does not exist'}
				return render_to_response('myevents/error.html', data, context_instance=RequestContext(request))
		else:
			return render_to_response('myevents/error.html', {'message':'invalid user'}, context_instance=RequestContext(request))

def getMyPastChoices(request, ehash, uhash):
	if request.method == 'GET':
		u = user.objects.get(uhash=uhash)
		cs = choice.objects.filter(addby_id=u.id)
		
		### TBD: only pick the most frequent five.
		data = serializers.serialize('json', cs)        
		return HttpResponse(data, mimetype='application/json')
	else:
		return render_to_response('myevents/error.html', {"message":"the request is not a get"}, context_instance=RequestContext(request))
	
# get the rating of the user for the place cid
def get_baseline_rating(uid, cid):
	p = poll.objects.filter(user_id = uid, choice_id = cid);
	flatsum = 0
	num = len(p)
	if num>0:
		for row in p:
			flatsum += row.vote
		return float(flatsum)/num
	else:
		return None  #if the user haven't voted the place(choice) before
	
def find_list_intersection(a,b):
	return set(a).intersection( set(b) )

#input list: compute mean and dev
def aggregate_rating(ratings):
	list_size = len(ratings)
	flatsum = 0.0
	squaresum = float(0)
	for r in ratings:
		flatsum += r
	mean = flatsum/list_size
	if list_size>1:
		for r in ratings:
			squaresum += (r-mean)**2
		variance = squaresum/(list_size - 1)
	else:
		variance = 0.0
	return  (flatsum,variance)
	  
def sort_items_by_score(mydict):
	itemlist = []
	newdict = sorted(mydict.iteritems(), key=lambda (k,v): (v,k), reverse=True)
	for k,v in newdict:
		#print "%s: %s" % (k,v)
		if v>0:
			itemlist.append(k)
	return itemlist
	
# input dict: key uid, value <item,rating> dict 
def build_baseline_reclist(user_rate):
	ulist = user_rate.values()
	item_union = {}
	for u in ulist:
		#u.keys= items. 
		for iid,rating in u.iteritems():
			if item_union.has_key(iid):
				item_union[iid].append(rating)
			else:
				item_union[iid]=[]
				item_union[iid].append(rating)
	#item_iid = []
	#item_score = []
	item_score_dict = {}
	for item in item_union.keys():
		values = item_union[item]
		#item_iid.append(item)
		(flatsum,var) = aggregate_rating(values)
		#item_score.append(0.9*mean-0.1*var)
		item_score_dict[item] = 0.9*flatsum - 0.1*var
	
	#sort item based on its score
	sorted_items=[]
	sorted_items = sort_items_by_score(item_score_dict)
	return sorted_items

# for attender add more choices
# baseline recommendation algorithm
def getBaseRecommendation2(request,ehash,uhash):
	if request.method == 'GET':
		e = event.objects.get(ehash=ehash)
		query_date = str(e.eventDate)
		query_zipcode = e.location

		conn = MySQLdb.connect(host = "localhost",user = "root", passwd = "fighting123", db = "mymovies")
		cursor = conn.cursor()
		if query_date and query_zipcode:
			query = 'select s.id, m.title, t.name, t.street,t.city,t.state,t.postcode, t.url, s.showtimes, m.img_id, t.fthid from  myevents_movie m, myevents_theatre t, myevents_schedule s where t.thid = s.thid and s.mov_id = m.mov_id and t.postcode = "'+query_zipcode+'" and s.date = "'+query_date+'"'
			#print query
			cursor.execute(query)
				
			rs = cursor.fetchall()
			#print rs
			cursor.close()
			conn.close()
			ys = {}
			i=0
			for row in rs:
				isValid=True
				if e.eventTime != 'All Day':
					times = row[8].strip().split(',')
					isValid = False
					for t in times: 
						if isValidTime(e.eventTime,t):
							isValid=True
							break
				if  isValid:
					#print row[0],row[1],row[2]
					address = row[3] +' '+ row[4] +' '+row[5]+' '+ row[6] 
					y = {}
					y['schedule_id'] = row[0]
					y['movie_title'] = row[1] 
					y['theatre_name'] = row[2]
					y['theatre_address'] = address
					y['theatre_url'] = row[7]
					y['showtimes'] = row[8]
					y['fandango_url'] = 'http://www.fandango.com/tms.asp?a=12625&m='+row[9] +'&t='+ row[10]
					ys[str(i)]=y
					i+=1
				
			#seralized_dict = simplejson.dumps(ys, default=lambda a: "[%s,%s]" % (a, a))
			data = simplejson.dumps(ys)
			#data = serializers.serialize('json', ys, indent=2, use_natural_keys=True) 
			return HttpResponse(data, mimetype='application/json')
		else:
			return render_to_response('myevents/error.html',{"message":"the zipcode and query date should not be empty"}, context_instance=RequestContext(request))
	else:
		return render_to_response('myevents/error.html', {"message":"the request is not a GET"}, context_instance=RequestContext(request))

# use this for attender add choices
def getSearchChoices2(request,ehash,uhash):
	#print ehash,uhash
	if request.method == 'POST':
		e = event.objects.get(ehash=ehash)
		mv_title = request.POST.get('mv_title', '')
		th_name = request.POST.get('th_name','')
		zipcode = request.POST.get('zipcode','')
		query_date = str(e.eventDate)
		conn = MySQLdb.connect(host = "localhost",user = "root", passwd = "fighting123", db = "mymovies")
		
		cursor = conn.cursor()
		if th_name and mv_title :
			query = 'select s.id, m.title, t.name, t.street,t.city,t.state,t.postcode, t.url, s.showtimes,m.img_id,t.fthid from myevents_movie m, myevents_theatre t, myevents_schedule s where t.thid = s.thid and s.mov_id = m.mov_id and t.postcode = "'+zipcode+'" and s.date = "'+query_date+'" and m.title like "%'+mv_title+'%" and t.name like "%' +th_name+'%"' 
		else:
			if mv_title: 
				query = 'select s.id, m.title, t.name, t.street,t.city,t.state,t.postcode, t.url, s.showtimes,m.img_id,t.fthid from myevents_movie m, myevents_theatre t, myevents_schedule s where t.thid = s.thid and s.mov_id = m.mov_id and t.postcode = "'+zipcode+'" and s.date = "'+query_date+'" and m.title like "%'+mv_title+'%"' 
			if th_name:
				query = 'select s.id, m.title, t.name, t.street,t.city,t.state,t.postcode, t.url, s.showtimes,m.img_id,t.fthid from myevents_movie m, myevents_theatre t, myevents_schedule s where t.thid = s.thid and s.mov_id = m.mov_id and t.postcode = "'+zipcode+'" and s.date = "'+query_date+'" and t.name like "%' +th_name+'%"' 
			
		#print query
		cursor.execute(query)
		rs = cursor.fetchall()
		#print rs
		cursor.close()
		conn.close()
		ys = {}
		i=0
		for row in rs:
			#print row[0],row[1],row[2]
			address = row[3] +' '+ row[4] +' '+row[5]+' '+ row[6] 
			isValid = True 
			if e.eventTime !='All Day':
				times = row[8].strip().split(',')
				isValid = False
				for t in times: 
					if isValidTime(e.eventTime,t):
						isValid=True
						break
					else:
						continue
			if isValid: 
				y={}           
				y['schedule_id'] = row[0]
				y['movie_title'] = row[1] 
				y['theatre_name'] = row[2]
				y['theatre_address'] = address
				y['theatre_url'] = row[7]
				y['showtimes'] = row[8]
				y['fandango_url'] = 'http://www.fandango.com/tms.asp?a=12625&m='+row[9] +'&t='+ row[10]
				ys[str(i)]=y
				i+=1
				
		data = simplejson.dumps(ys)
		return HttpResponse(data, mimetype='application/json')
	else:
		return render_to_response('myevents/error.html', {"message":"the request is not a POST"}, context_instance=RequestContext(request))

def getSearchChoices(request,ehash,uhash=None):
	#print ehash,uhash
	if request.method == 'POST':
		e = event.objects.get(ehash=ehash)
		mv_title = request.POST.get('mv_title', '')
		th_name = request.POST.get('th_name','')
		zipcode = request.POST.get('zipcode','')
		query_date = str(e.eventDate)
		conn = MySQLdb.connect(host = "localhost",user = "root", passwd = "fighting123", db = "mymovies")
		
		cursor = conn.cursor()
		if th_name and mv_title :
			query = 'select s.id, m.title, t.name, t.street,t.city,t.state,t.postcode, t.url, s.showtimes, m.img_id,t.fthid from myevents_movie m, myevents_theatre t, myevents_schedule s where t.thid = s.thid and s.mov_id = m.mov_id and t.postcode = "'+zipcode+'" and s.date = "'+query_date+'" and m.title like "%'+mv_title+'%" and t.name like "%' +th_name+'%"' 
		else:
			if mv_title: 
				query = 'select s.id, m.title, t.name, t.street,t.city, t.state, t.postcode, t.url, s.showtimes,m.img_id,t.fthid from myevents_movie m, myevents_theatre t, myevents_schedule s where t.thid = s.thid and s.mov_id = m.mov_id and t.postcode = "'+zipcode+'" and s.date = "'+query_date+'" and m.title like "%'+mv_title+'%"' 
			if th_name:
				query = 'select s.id, m.title, t.name, t.street,t.city, t.state, t.postcode, t.url, s.showtimes,m.img_id,t.fthid from myevents_movie m, myevents_theatre t, myevents_schedule s where t.thid = s.thid and s.mov_id = m.mov_id and t.postcode = "'+zipcode+'" and s.date = "'+query_date+'" and t.name like "%' +th_name+'%"' 
			
		#print query
		cursor.execute(query)
		rs = cursor.fetchall()
		#print rs
		cursor.close()
		conn.close()

		ys = {}
		i=0
		for row in rs:
			#print row[0],row[1],row[2]
			address = row[3] +' '+ row[4] +' '+row[5]+' '+ row[6] 
			isValid = True 
			if e.eventTime != 'All Day':
				times = row[8].strip().split(',')
				isValid = False
				for t in times: 
					if isValidTime(e.eventTime,t):
						isValid = True
						break
			if isValid:    
				y={}
				y['schedule_id'] = row[0]
				y['movie_title'] = row[1] 
				y['theatre_name'] = row[2]
				y['theatre_address'] = address
				y['theatre_url'] = row[7]
				y['showtimes'] = row[8]
				y['fandango_url'] = 'http://www.fandango.com/tms.asp?a=12625&m='+row[9] +'&t='+ row[10]
				ys[str(i)]=y
				i+=1
		
			#seralized_dict = simplejson.dumps(ys, default=lambda a: "[%s,%s]" % (a, a))
		data = simplejson.dumps(ys)
			#data = serializers.serialize('json', ys, indent=2, use_natural_keys=True) 
		return HttpResponse(data, mimetype='application/json')
	else:
		return render_to_response('myevents/error.html', {"message":"the request is not a POST"}, context_instance=RequestContext(request))


def getBaseRecommendation(request,ehash,uhash=None):
	#print ehash,uhash
	if request.method == 'GET':
		e = event.objects.get(ehash=ehash)
		query_date = str(e.eventDate)
		query_zipcode = e.location.strip()

		conn = MySQLdb.connect(host = "localhost",user = "root", passwd = "fighting123", db = "mymovies")
		cursor = conn.cursor()

		if query_date and query_zipcode:
			query = 'select s.id, m.title,t.name, t.street,t.city,t.state,t.postcode, t.url, s.showtimes, m.img_id, t.fthid  from  myevents_movie m, myevents_theatre t, myevents_schedule s where t.thid = s.thid and s.mov_id = m.mov_id and t.postcode = "'+query_zipcode+'" and s.date = "'+query_date+'"'
			print query

			cursor.execute(query)
				
			rs = cursor.fetchall()
			#print rs
			cursor.close()
			conn.close()
			ys = {}
			i=0
			for row in rs:
				#print row[0],row[1],row[2]
				address = row[3] +' '+ row[4] +' '+row[5]+' '+ row[6] 
				y = {}
			   
				isValid=True 
				if e.eventTime !='All Day':
					times = row[8].strip().split(',')   
					isValid = False
					for t in times: 
						if isValidTime(e.eventTime,t):
							isValid=True
							break
				if isValid:    
					y['schedule_id'] = row[0]
					y['movie_title'] = row[1] 
					y['theatre_name'] = row[2]
					y['theatre_address'] = address
					y['theatre_url'] = row[7]
					y['showtimes'] = row[8]
					y['fandango_url'] = 'http://www.fandango.com/tms.asp?a=12625&m='+row[9] +'&t='+ row[10]
					#print y['fandango_url']
					ys[str(i)]=y
					i+=1

			#seralized_dict = simplejson.dumps(ys, default=lambda a: "[%s,%s]" % (a, a))
			data = simplejson.dumps(ys)
			#data = serializers.serialize('json', ys, indent=2, use_natural_keys=True) 
			return HttpResponse(data, mimetype='application/json')
		else:
			return render_to_response('myevents/error.html',{"message":"the zipcode and query date should not be empty"}, context_instance=RequestContext(request))
	else:
		return render_to_response('myevents/error.html', {"message":"the request is not a GET"}, context_instance=RequestContext(request))

# use item rather than different types
def editEventChoice(request, ehash,uhash=None):
	if request.method == "POST":
		admin_choices = request.POST.getlist('admin_choice_ids')
		try: 
			choice_objs = {}
			e = event.objects.get(ehash=ehash)
			if uhash is None:
				uid = request.session['user_id']
				if uid is None:
					return render_to_response('myevents/error.html', {"message":"invalid user"}, context_instance=RequestContext(request))      
				else:
					inviter = user.objects.get(id=uid)
			else:
				inviter = user.objects.get(uhash=uhash)
			
			i=0
			for cid in admin_choices:
				try:
					s = schedule.objects.get(id=cid)
				except schedule.DoesNotExist:
					return render_to_response('myevents/error.html', {"message":"invalid schedule"}, context_instance=RequestContext(request))      
				
				try:
					c = choice.objects.get(event_id=e.id,schedule_id=cid,pickby_id=inviter.id)
					c.cnt+=1
					c.save()
				except choice.DoesNotExist:
					c = choice.objects.create(event_id= e.id,schedule_id=cid, pickby_id=inviter.id,cnt=1) 
				#try: # here is for wrong operation. shouldn't happen if not because of testing
				#    ec = event_choice.objects.get(event_id= e.id,choice_id=c.id)
				#except:
				#    ec = event_choice.objects.create(event_id=e.id, choice_id=c.id)
				#item_obj = item.objects.get(id=cid)
				y={}
				t = theatre.objects.get(thid = s.thid)
				m = movie.objects.get(mov_id=s.mov_id)
				y['movie_title'] = m.title 
				y['theatre_name'] = t.name
				y['theatre_address'] = t.street+' '+t.city+' '+t.state+' '+t.postcode
				y['theatre_url'] = t.url
				y['showtimes'] = s.showtimes
				y['fandango_url'] = 'http://www.fandango.com/tms.asp?a=12625&m='+m.img_id +'&t='+ t.fthid
				choice_objs[str(i)]=y
				i+=1
				
			#seralized_dict = simplejson.dumps(ys, default=lambda a: "[%s,%s]" % (a, a))
					
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
			
			# pass back user for indentification
			data = {'event': e, 'user':inviter, 'choices':choice_objs}                                                                                                                                       
			#data = simplejson.dumps(choice_objs) 
			#print data
			return render_to_response('myevents/success.html', data, context_instance=RequestContext(request))
		except event.DoesNotExist or user.DoesNotExist:
			return render_to_response('myevents/error.html', {"message":"event does not exist"}, context_instance=RequestContext(request))      

#attender add more choice. form update
def addMoreChoice(request,ehash,uhash):
	if request.method == "POST":
		attender_choices = request.POST.getlist('attender_choice_ids')
		try: 
			choice_objs = []
			e = event.objects.get(ehash=ehash)
			proposer = user.objects.get(uhash=uhash)
			for cid in attender_choices:
				try:
					c = choice.objects.get(event_id = e.id,schedule_id=cid,pickby_id=proposer.id)
					c.cnt+=1
					c.save()
				except choice.DoesNotExist:
					c = choice.objects.create(event_id=e.id,schedule_id=cid, pickby_id=proposer.id,cnt=1) 
					
			### send a mail to inviter too, since he is the attender as well
			all_attenders = db_get_all_attender_emails(e.id)
			all_attenders.append(e.inviter)  #include the inviter

			### send email to each attender 
			for each_attender in all_attenders:
				#remove space
				each_attender = each_attender.strip()    
				try:
					attender = user.objects.get(email=each_attender)
					newChoiceNotificationMail(ehash, attender.uhash, proposer.email, e.name, attender.email)
				except user.DoesNotExist:   #ignore the user which doesn't exist in the db
					continue

			data = {'event': e, 'user':proposer}        
			return render_to_response('myevents/addChoiceSuccess.html', data, context_instance=RequestContext(request))
		except event.DoesNotExist or user.DoesNotExist:
			return render_to_response('myevents/error.html', {"message":"event or user does not exist"}, context_instance=RequestContext(request))      
		
	  
# NOT USED 7-27 
def editEventChoice2(request, ehash, uhash):
	if request.method == "POST":
		manual_choices = request.POST.getlist('manual_choice_ids')
		#print manual_choices
		yelp_choices = request.POST.getlist('yelp_choice_ids')
		#print yelp_choices
		rec_choices = request.POST.getlist('rec_choice_ids')
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
				manual_c = item.objects.get(id=cid)
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
				
			for cid in rec_choices:
				try:
					c = choice.objects.get(pickid=cid, pickfrom=CHOICE_SOURCE.REC, pickby_id=inviter.id)
					c.cnt +=1
					c.save()
				except choice.DoesNotExist:
					c = choice.objects.create(pickid=cid, pickfrom=CHOICE_SOURCE.REC, pickby_id=inviter.id,cnt=1)
				try: # here is for wrong operation. shouldn't happen if not because of testing
					ec = event_choice.objects.get(event_id= e.id,choice_id=c.id)
				except:
					ec = event_choice.objects.create(event_id=e.id, choice_id=c.id)
				# yelp data table is separated from item.
				rec_c = item.objects.get(id=cid)
				choice_objs.append(rec_c)
				
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
		  

