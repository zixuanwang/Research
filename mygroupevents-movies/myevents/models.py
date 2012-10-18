##
## initial update for movie 9/27/2012
## Jinyun
##

from django.db import models
 
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
	inviter = models.CharField(max_length=255, null=True)
	friends = models.TextField(null=True)
	finalChoice = models.TextField(null=True)
	eventDate = models.DateField(editable=True)
	eventTime = models.CharField(max_length=255,null=True)
	closeDate =  models.DateTimeField(editable=True)
	pub_date = models.DateTimeField(auto_now_add=True)

class theatre(models.Model):
	thid = models.CharField(max_length=25)
	fthid = models.CharField(max_length=25)
	name = models.TextField()
	street = models.TextField()
	city = models.TextField()
	state = models.TextField()
	country = models.TextField()
	postcode = models.CharField(max_length=25)
	telephone = models.CharField(max_length=25)
	longitude = models.CharField(max_length=255)
	latitude = models.CharField(max_length=255)
	url = models.TextField(null=True) 

class movie(models.Model):
	mov_id = models.CharField(max_length=255)
	title = models.CharField(max_length=255)
	# exists more than one red, pick the first one, or concatenate by symbol
	description = models.TextField()
	# use , connect if more than one genre
	genre = models.CharField(max_length=255)
	release_date = models.CharField(max_length=255)
	img_id = models.CharField(max_length=255)

class schedule(models.Model):
	mov_id = models.CharField(max_length=1024)
	thid = models.CharField(max_length = 1024)
	date = models.CharField(max_length = 1024)
	showtimes = models.TextField()
	
class search_query(models.Model):
	theater_name = models.TextField()
	movie_name = models.TextField()
	zipcode = models.CharField(max_length=100)
	date = models.CharField(max_length=100)
	search_by = models.ForeignKey(user)
	search_for = models.ForeignKey(event)
	pub_date = models.DateTimeField( auto_now_add=True)

# result is program. by default has all valid time 
# either set time invalid in schedule 
# or add schedule into choice only if the showtime is valid
class search_result(models.Model):
	search_query = models.ForeignKey(search_query)
	schedule = models.ForeignKey(schedule)

class event_user(models.Model):
	event = models.ForeignKey(event)
	user = models.ForeignKey(user)
	role = models.CharField(max_length=100)
	join_date = models.DateTimeField(auto_now=True, auto_now_add=True)

# in the next confirmation page
# need to delete some schedules if admin decides so
class choice(models.Model):
	event = models.ForeignKey(event)
	schedule = models.ForeignKey(schedule)
	pickby = models.ForeignKey(user)
	pub_date = models.DateTimeField(auto_now=True, auto_now_add=True)
	cnt = models.IntegerField()

class poll(models.Model):
	event = models.ForeignKey(event)
	choice = models.ForeignKey(choice)
	user = models.ForeignKey(user)
	vote = models.IntegerField()
	date = models.DateTimeField(auto_now=True, auto_now_add=True)

# record all clicks of a user made to a choice for an event 
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

