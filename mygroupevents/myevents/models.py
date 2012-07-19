
from django.db import models
 
# Create your models here.
# create index user_email on myevents_user(email);
class user(models.Model):
	uhash = models.CharField(max_length=36)
	name = models.CharField(max_length=255)
	email = models.EmailField(max_length=100)
	passwd = models.CharField(max_length=100)
	
# cnt is the number of time u and v appear in the same event
class friend(models.Model):
	u = models.ForeignKey(user,related_name='inviter')
	v = models.ForeignKey(user,related_name='attender')
	cnt = models.IntegerField()
	
class event(models.Model):
	ehash = models.CharField(max_length=36)
	name = models.CharField(max_length=255)
	detail = models.TextField()
	what_other = models.TextField(null=True)
	status = models.CharField(max_length=255)
	location = models.TextField(null=True)
	#zipcode = models.CharField(max_length=255, null=True)
	#city = models.CharField(max_length=255, null=True)
	inviter = models.CharField(max_length=255, null=True)
	friends = models.TextField(null=True)
	finalChoice = models.TextField(null=True)
	eventDate = models.DateField(editable=True)
	eventTime = models.CharField(max_length=255,null=True)
	closeDate =  models.DateTimeField(editable=True)
	pub_date = models.DateTimeField(auto_now_add=True)

class manual(models.Model):
	name = models.TextField()
	location = models.TextField()
	notes = models.TextField(null=True)
	image = models.TextField(null=True)
	addby = models.ForeignKey(user)

#create index choice_pickid on myevents_choice(pickid);
class choice(models.Model):
	pickfrom = models.TextField()
	pickid = models.IntegerField()
	pickby = models.ForeignKey(user)
	cnt = models.IntegerField()
	pub_date = models.DateTimeField(auto_now_add=True)

# the returned results of yelp search! 
# create INDEX yelp_id ON myevents_yelp(yid(256))
class yelp(models.Model):
#	yid = models.TextField(null=True)
# name = models.TextField()
	yid = models.CharField(max_length=1024,null=True)
	name = models.CharField(max_length=1024)
	image_url = models.TextField(null=True)
	url = models.TextField(null=True)
	mobile_url = models.TextField(null=True)
	phone = models.TextField(null=True)
	display_phone= models.TextField(null=True)
	review_count = models.IntegerField(null=True)
	categories = models.TextField(null=True)
	rating = models.TextField(null=True)
	rating_img_url = models.TextField(null=True)
	rating_img_url_small = models.TextField(null=True)
	rating_img_url_large = models.TextField(null=True)
	snippet_text = models.TextField(null=True)
	snippet_image_url = models.TextField(null=True)
#	location = models.TextField(null=True)
	location_coordinate_latitude = models.TextField(null=True)
	location_coordinate_longitude = models.TextField(null=True)
	location_address = models.TextField(null=True)
	location_display_address = models.TextField(null=True)
	location_city= models.TextField(null=True)
	location_state_code = models.TextField(null=True)
	location_postal_code = models.TextField(null=True)
	location_country_code = models.TextField(null=True)
	location_cross_streets = models.TextField(null=True)
	location_neighborhoods = models.TextField(null=True)
	location_geo_accuracy = models.TextField(null=True)
	#location = models.TextField()
	##phone = models.TextField(null=True)
	##notes = phone
	#notes = models.TextField(null=True)
	#rating = models.IntegerField(null=True)
	#where = models.TextField()
	#query = models.TextField()
	#what = models.TextField()
	#longtitude = models.CharField(max_length=1024,null=True)
	#latitude = models.CharField(max_length=1024,null=True)
	#url = models.TextField()
	pub_date = models.DateTimeField(auto_now_add=True)
	
class item(models.Model):
	#this foreign_id is for yelp id, or manual id, or id from any other data source. not used now
	foreign_id = models.IntegerField()
	name = models.CharField(max_length=1024)
	location = models.TextField()
	notes = models.TextField(null=True)
	image = models.TextField(null=True)
	url = models.TextField(null=True)
	type = models.IntegerField()

class search_query(models.Model):
	term = models.TextField()
	location = models.TextField()
	search_by = models.ForeignKey(user)
	search_for = models.ForeignKey(event)
	pub_date = models.DateTimeField( auto_now_add=True)

class search_result(models.Model):
	query = models.ForeignKey(search_query)
	yelp_result = models.ForeignKey(yelp)	
	
class event_user(models.Model):
	event = models.ForeignKey(event)
	user = models.ForeignKey(user)
	role = models.CharField(max_length=100)

class event_choice(models.Model):
	event = models.ForeignKey(event)
	choice = models.ForeignKey(choice)
#	#addedby = models.ForeignKey(user)
#	pick_from = models.IntegerField()
	pub_date = models.DateTimeField(auto_now=True, auto_now_add=True)

class poll(models.Model):
	event = models.ForeignKey(event)
	choice = models.ForeignKey(choice)
	user = models.ForeignKey(user)
	vote = models.IntegerField()
	date = models.DateTimeField(auto_now=True, auto_now_add=True)

class comment(models.Model):
	event = models.ForeignKey(event)
	user = models.ForeignKey(user)
	say = models.TextField()
	pub_date = models.DateTimeField(auto_now_add=True)
	
class review(models.Model):
	name = models.CharField(max_length=1024)
	comment = models.TextField()
	pub_date = models.DateTimeField(auto_now_add=True)
