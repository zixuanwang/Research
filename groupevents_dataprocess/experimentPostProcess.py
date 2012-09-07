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
	pass	

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

def get_all_categories(filename,filename2):
	f = open(filename,'r')
	category = {}
	for line in f:
		terms= line.strip().split('\t')
		print terms[0]
		print terms[1]
		t = terms[1].replace(';',',')
		cats = t.lower().split(',')
		for c in cats:
			try:
				category[c] = category[c] + 1
			except KeyError:
				category[c] = 1
	f.close()
	of = open(filename2,'w')
	for k,v in category.items():
		of.write(k+'\t' + str(v) +'\n')
	of.close()

def place_category_matrix(file1,file2,file3):
	place_cat_f = open(file1,'r')
	cat_f = open(file2,'r')
	matrix_of = open(file3,'w')
	
	cats = []
	for line in cat_f:
		terms = line.strip().split('\t')
		cats.append(terms[0])
	#print cats

	for line in place_cat_f:
		terms = line.strip().split('\t')
		t = terms[1].lower().replace(';',',')
		ts = set(t.split(','))
		#print ts
		ans = []
		for c in cats:
			if c in ts:
				ans.append('1')
			else:
				ans.append('0')
		matrix_of.write(','.join(ans)+'\n')

#get_all_categories('yelp_id_category.txt','yelp_category_frequence.txt')
place_category_matrix('yelp_id_category.txt','yelp_category_frequence.txt','place_category_matrix.txt')	
