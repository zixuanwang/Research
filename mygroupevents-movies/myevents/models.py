
from django.db import models
 
# Create your models here.
# create index user_email on myevents_user(email);
class user(models.Model):
	uhash = models.CharField(max_length=36)
	name = models.CharField(max_length=255)
	email = models.EmailField(max_length=100)
	passwd = models.CharField(max_length=128)
	is_registered=models.IntegerField()
	is_active=models.IntegerField()
	date_join = models.DateTimeField(editable=True)
	last_login = models.DateTimeField(auto_now_add=True)
	def is_authenticated(self):
		if self.is_registered:
			return True
		else:
			return False	
	
# cnt is the number of time u and v appear in the same event
class friend(models.Model):
	u = models.ForeignKey(user,related_name='inviter')
	v = models.ForeignKey(user,related_name='attender')
	cnt = models.IntegerField()
	
class event(models.Model):
	ehash = models.CharField(max_length=36)
	name = models.CharField(max_length=255)
	detail = models.TextField(null=True)
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

class theater(models.Model):
	theatreId = models.CharField(max_length=25)
	name = models.TextField()
	address_street1 = models.TextField()
	address_city = models.TextField()
	address_state = models.TextField()
	address_postalCode = models.CharField(max_length=25)
	telephone = models.CharField(max_length=25)
	screenCount = models.IntegerField()
	longitude = models.CharField(max_length=255)
	latitude = models.CharField(max_length=255)
	active =  models.IntegerField()
	url = models.TextField(null=True) 

class schedule(models.Model):
	theater = models.ForeignKey(theater)
	movie = models.ForeignKey(movie)
	show_date = models.DateTimeField(editable=True)
	show_time = models.TimeField(editable=True)
	barg = models.IntegerField()
	
class movie(models.Model):
	tmsid = models.CharField(max_length=255)
	title_full = models.CharField(max_length=255)
	# exists more than one red, pick the first one, or concatenate by symbol
	title_red = models.CharField(max_length=255)
	desc_500 = models.TextField()
	desc_250 = models.TextField()
	desc_100 = models.TextField()
	desc_60 = models.TextField()
	progType = models.CharField(max_length=255)
	# use , connect if more than one genre
	genre = models.CharField(max_length=255)
	qualityRating = models.FloatField()
	pictureFormat = models.CharField(max_length=255)
	releases = models.CharField(max_length=255)
	productionCompanies = models.CharField(max_length=255)
	country = models.CharField(max_length=25)
	# use symbol to concatenate distributor names if more than one. 
	distributors = models.CharField(max_length=255)

class celebrity(models.Model)
	firstname = models.CharField(max_length=255)
	lastname = models.CharField(max_length=255)

class movie_cast(models.Model):
	movie = models.ForeignKey(movie)
	celebrity = models.ForeignKey(celebrity)
	role = models.CharField(max_length=255)
	char_firstname = 	models.CharField(max_length=255)
	char_lastname = models.CharField(max_length=255)

class movie_award(models.Model):
	movie = models.ForeignKey(movie)
	award_name = models.CharField(max_length=255)
	category = models.CharField(max_length=255)
	recipient = models.CharField(max_length=255)
	year = models.CharField(max_length=255)
	
class movie_rating(models.Model):
	movie = models.ForeignKey(movie)
	area = models.CharField(max_length=255)
	code = models.CharField(max_length=255)
	
class manual(models.Model):
	name = models.TextField()
	location = models.TextField()
	notes = models.TextField(null=True)
	image = models.TextField(null=True)
	addby = models.ForeignKey(user)

# the returned results of yelp search! 
# create INDEX yelp_id ON myevents_yelp(yid(256))
class yelp(models.Model):
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
	#this foreign_id is for yelp id, or manual id, or id from any other data source. 
	foreign_id = models.IntegerField()
	name = models.CharField(max_length=1024)
	location = models.TextField()
	notes = models.TextField(null=True)
	image = models.TextField(null=True)
	url = models.TextField(null=True)
	#where item is from. yelp or manual.
	ftype = models.IntegerField()   

#create index choice_pickid on myevents_choice(pickid);
class choice(models.Model):
	#here uses item id.
	pickid = models.IntegerField()
	pickby = models.ForeignKey(user)
	cnt = models.IntegerField()
	pub_date = models.DateTimeField(auto_now_add=True)
	
class search_query(models.Model):
	term = models.TextField()
	location = models.TextField()
	search_by = models.ForeignKey(user)
	search_for = models.ForeignKey(event)
	pub_date = models.DateTimeField( auto_now_add=True)

class search_result(models.Model):
	query = models.ForeignKey(search_query)
	yelp_result = models.ForeignKey(yelp)	

#todo 9-2-2012: need pub_date. to display events by date and time
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

#record all clicks of a user made to a choice for an event 
class pollClick(models.Model):
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

