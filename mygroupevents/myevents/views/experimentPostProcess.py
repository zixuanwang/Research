from myevents.models import * 
from globalHeader import *
import datetime
import random
import math

def get_active_users():
	us = user.objects.filter(is_active=True,is_registered=True)
	return us

def get_used_places():
	pls = []
	ecs = event_choice.objects.getall()
	for row in ecs: 
		pid = choice.objects.get(id= row.choice_id).pickid
		pl = item.objects.get(id = pid)
		pls.append(pl)
	return pls

def get_item_features(iid):
	item_instance = item.objects.get(id=iid)
	if ftype==CHOICE_SOURCE.YELP:
		yelp_instance = yelp.objects.get(id=item_instance.foreign_id)	
		print yelp.name, yelp.url


def send_yelp_query():


# use positive fraction so far
def get_vote_byuser_forplace(u,p):
	

def build_user_place_matrix():			
	us = get_active_users()
	pls = get_used_places()
	print 'No of users: %i'%len(us)
	print 'No of places: %i'%len(pls)

	for u in us:
		for p in pls:
			v = get_vote_byuser_forplace(u,p)


