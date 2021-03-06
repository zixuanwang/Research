from myevents.models import * 
from globalHeader import *
import datetime
import random
import math
from bs4 import BeautifulSoup

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
		parser_yelp(yelp.url)

def parser_yelp(url):
	base_url = 'http://www.yelp.com'
	f = urllib.urlopen(url)
	soup = BeautifulSoup(f.read())
	f.close()
	allcomments = []
	page1 = soup.findAll('p','review_comment')
	for p in page1:
		#print p.contents
		allcomments.append(p.contents)
	#get next pages : has div pagination_controls
	#get all next urls 
	next_pages = soup.find('div','pagination_controls').find('table')
	for nextp in next_pages.findAll('a'):
		link =  nextp['href']
		if link != None:
			print link
			newurl = base_url+link
			newf = urllib.urlopen(newurl)
			sp = BeautifulSoup(newf.read())
			newf.close()
			newcomment = sp.findAll('p','review_comment')
			for p in newcomment:
				allcomments.append(p.contents)				
	
	print 'total number of comments:%i'%len(allcomments)
	for c in allcomments: 			
		print c	

# use positive fraction so far
def get_vote_byuser_forplace(u,p):
	pass	

def build_user_place_matrix():			
	us = get_active_users()
	pls = get_used_places()
	print 'No of users: %i'%len(us)
	print 'No of places: %i'%len(pls)

	for u in us:
		for p in pls:
			v = get_vote_byuser_forplace(u,p)


