from myevents.models import * 
from globalHeader import *
import datetime
from passlib.apps import custom_app_context as pwd_context
import random
import math
def createAccounts():
	f= open('/home/jane/workspace/Research/technicolor_email_list.txt','r')
	for line in f:
		user_email = line.strip()
		user_passwd='$Technicolor1'
		salted_hash_password = pwd_context.encrypt(user_passwd)
		date_join= datetime.datetime.now()
		uhash =  make_uuid()
		user_name = getNamebyEmail(user_email)
		u = user.objects.create(name=user_name, email=user_email, passwd=salted_hash_password, uhash=uhash, is_registered=True, is_active=True,date_join=date_join)
	
def createRestaurants(category="restaurants",query="restaurants",location="palo alto"):
	url_params={}
	url_params['term'] = query
	url_params['location'] = location
	url_params['limit'] = "20"
	url_params['radius_filter'] = "3800"
	url_params['category_filter'] = category

	consumer_key = '4cJ1ZEMrBdiv4pFLj8AtDA'
	consumer_secret = '93EEwlZWhuzx2TrZzXWf847RFNE'
	token =  'CgZGSsOcAQ1nD6J8WIcKZi4up_mDflsw'
	token_secret =  'nwYBgTQb112p4j9F5_BqrP2iLlw'

	response = yelp_request("api.yelp.com", '/v2/search', url_params, consumer_key, consumer_secret,  token,  token_secret)
	# returned error
	if not response.has_key('businesses'):
		print response
		return  False
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
	
	
def activeUser(user_email):
	u = user.objects.get(email=user_email)
	u.is_active=True
	u.save()
			
def disactiveUser(user_email):
	u = user.objects.get(email=user_email)
	u.is_active=False
	u.save()
		
def disactiveManyUsers():
	disactiveUser("salman.salamatian@gmail.com")
	disactiveUser("jbento@stanford.edu")
	disactiveUser("smewtoo@gmail.com")
	disactiveUser("thibaut.horel@gmail.com")
	disactiveUser("mathildecaron94@gmail.com")
	disactiveUser("flavio@mit.edu")
	disactiveUser("jeanbolot@gmail.com")
	
#range(k+1,n+1) : k+1 ... n+1
#list: 0..n-1
def random_sample_list(item_list, k):
	n = len(item_list)
	random.seed(int(time.time()))
	for i in range(k+1,n+1):
		j = int(math.ceil(random.random()*k))
		#print "i,j: %i,%i"%(i,j)
		if j<=k:
			tmp = item_list[j]
			item_list[j] = item_list[i-1] 
			item_list[i-1] = tmp
	return item_list

#sample items for n events
#number of items is fixed to be 6
def random_sample_items(n):
	ys = item.objects.all()
	item_ids = []
	for y in ys:
		item_ids.append(y.id)
	for i in range(n):
		random.seed(int(time.time()))
		random.shuffle(item_ids)   #shuffle ids all the time
		print item_ids[0:6]

def create_event(event_name,event_date,event_time,members,item_ids):
	print event_name,event_date, event_time,members
	e_hash = make_uuid()
	admin_u = user.objects.get(id=members[0])
	close_date = datetime.datetime.now() + datetime.timedelta(days=7)
	e = event.objects.create(name=event_name,ehash=e_hash,inviter=admin_u.email, detail="dining out", location="palo alto", eventDate=event_date,eventTime=event_time,closeDate=close_date,status=EVENT_STATUS.INIT)
	eu = event_user.objects.create(event_id = e.id, user_id=admin_u.id,role="admin")
	friend_emails = []
	for uid in members[1:]:
		attender_u = user.objects.get(id=uid)
		friend_emails.append(attender_u.email)
		#update event_user
		eu = event_user.objects.create(event_id = e.id, user_id=attender_u.id,role="attender")
		#update friendship
		try:
			uv = friend.objects.get(u_id=admin_u.id, v_id=attender_u.id)
			uv.cnt = uv.cnt +1
			uv.save()
		except friend.DoesNotExist:
			try:
				uv= friend.objects.get(v_id=admin_u.id, u_id=attender_u.id)
				uv.cnt +=1
				uv.save()
			except friend.DoesNotExist:
				uv = friend.objects.create(u_id=admin_u.id, v_id=attender_u.id,cnt=1)
	#select choice randomly, update event_choice
	random.shuffle(item_ids)   #shuffle ids all the time
	print item_ids[0:6]
	for cid in item_ids[0:6]:  #select first 6 items
		try:
			c = choice.objects.get(pickid=cid,pickby_id=admin_u.id)
			c.cnt +=1
			c.save()
			ec = event_choice.objects.create(event_id=e.id, choice_id=c.id)
		except choice.DoesNotExist:
			c = choice.objects.create(pickid=cid, pickby_id=admin_u.id,cnt=1)
			ec = event_choice.objects.create(event_id=e.id, choice_id=c.id)
	#update event
	e.friends =','.join(friend_emails)
	e.status = EVENT_STATUS.VOTING
	e.save()
		
def createItems():
	yelp_item = yelp.objects.all()
	for y in yelp_item:
		location =y.location_display_address
		newitem = item.objects.create(foreign_id=y.id, name=y.name, location=location, image=y.rating_img_url,notes=y.review_count,url=y.url,ftype=CHOICE_SOURCE.TEST)
		

def createDetails():
	all_users = user.objects.filter(is_active=True)
	id_list = []
	for row in all_users:
		id_list.append(row.id)
	ys = item.objects.all()
	item_ids = []
	for y in ys:
		item_ids.append(y.id)

	group_size = [2,4,8]
	event_date = ["2012-09-04","2012-09-05","2012-09-06","2012-09-08","2012-09-10","2012-09-11","2012-09-12","2012-09-13","2012-09-14","2012-09-15",
				"2012-09-17","2012-09-18","2012-09-19","2012-09-20","2012-09-21","2012-09-22","2012-09-24","2012-09-25","2012-09-26","2012-09-27","2012-09-28","2012-09-29",
			"2012-10-01","2012-10-03","2012-10-04","2012-10-05","2012-10-06"]
	event_times = ["12:01","18:01"] 
	event_title = ["Lunch","Dinner"]
	event_cnt = 0
	for one_date in event_date:
		random.seed(int(time.time()))
		for event_time in event_times:
			if event_time=="12:01":
				event_name = "Lunch"
			else:
				event_name = "Dinner"
			sampled_list = random_sample_list(id_list,8)
			
			group_eight = sampled_list[0:8]
			left_list = sampled_list[8:]
			event_cnt +=1 	
			create_event(event_name,one_date, event_time,group_eight,item_ids)
			
			sample_four = random_sample_list(left_list,4)
			
			create_event(event_name,one_date,event_time,sample_four[0:4],item_ids)
		
			event_cnt +=1 	
			sample_four_twice= random_sample_list(sample_four[4:],4)
			
			create_event(event_name,one_date,event_time,sample_four_twice[0:4],item_ids)
			
			event_cnt +=1 	
			sample_two = random_sample_list(sample_four_twice[4:],2)
			
			create_event(event_name,one_date,event_time,sample_two[0:2],item_ids)
			
			event_cnt +=1 	
			create_event(event_name,one_date,event_time,sample_two[2:4],item_ids)
			event_cnt +=1 	

	print "create %i events in total"%event_cnt
	
	
