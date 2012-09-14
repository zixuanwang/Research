from myevents.models import *
from myevents.views import *
from globalHeader import *
import datetime
import random
import math
#from bs4 import BeautifulSoup
import urllib
import unicodedata
import os

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
		#allcomments.append(p.contents)
		allcomments.append(p.get_text(' ',strip=True))
	#get next pages : has div pagination_controls
	#get all next urls 
	next_pages = soup.find('div','pagination_controls').find('table')
	for nextp in next_pages.findAll('a'):
		link =  nextp['href']
		if link != None:
			#print link
			newurl = base_url+link
			newf = urllib.urlopen(newurl)
			sp = BeautifulSoup(newf.read())
			newf.close()
			newcomment = sp.findAll('p','review_comment')
			for p in newcomment:
				#allcomments.append(p.contents)				
				allcomments.append(p.get_text(' ',strip=True))				
	
	print 'total number of comments:%i'%len(allcomments)
	return allcomments	

def select_restaurants(filename):
	f = open(filename,'r')
	data_folder='./yelp_reviews/'
	for line in f.readlines():
		terms = line.strip().split('\t')
		yelp_id = terms[0]
		yelp_url = terms[1]
		allcomments = parser_yelp(yelp_url)
		
		of = open(data_folder+yelp_id, 'w')
		for c in allcomments:
			print len(c)
			print c
			strc = unicodedata.normalize('NFKD', unicode(c)).encode('ascii','ignore')
			of.write(strc+'\n')
		of.close()	

def store_yelp_html_pages(filename):
	f = open(filename,'r')
	for line in f:
		terms = line.strip().split('\t')
		print terms[0]	
		print terms[1]
		html = urllib.urlopen(terms[1])
		of = open(os.path.join('yelp_html',terms[0]),'w')
		of.write(html.read())
		of.close()
		
def parse_one_bussiness_info(filename, outputfile):
	f = open(filename,'r')
	soup = BeautifulSoup(f.read())
	f.close()
	outf = open(outputfile,'w')
	div= soup.find('div',{'id':'bizAdditionalInfo'})
	if div:
		dts = div.findAll('dt')
		for dt in dts:
			dd = div.find('dd',{'class':dt['class']})
			dcontent = dd.get_text().strip()
			dcontent = dcontent.replace('\n',';')
			print '%s:%s'%(dt.get_text().strip(),dcontent)
			outf.write('%s:%s\n'%(dt.get_text().strip(),dcontent))
	else:	
		print '%s can not find bizAdditionalInfo!'%filename
	outf.close()

def parse_bussiness_info(infolder,outfolder):
	dirlist = os.listdir(infolder)
	for filename in dirlist:
		filename = filename.strip()
		f = parse_one_bussiness_info(os.path.join(infolder,filename),os.path.join(outfolder,filename))

def get_bz_info_frequence(infolder):
	dirlist = os.listdir(infolder)
	bzdict = {}
	for filename in dirlist:
		filename = filename.strip()
		f = open(os.path.join(infolder, filename),'r')
		for line in f:
			terms = line.strip().split(':')
			key = terms[0].lower()
			try:
				bzdict[key] = bzdict[key]+1
			except KeyError:
				bzdict[key] = 1		
	
	#sort by frequency,return a list
	bz_sort = sorted(bzdict.iteritems(), key=lambda (k,v): (v,k), reverse=True)	
	outf = open('bzinfo_requence.txt','w')
	for k in bz_sort:
		print k[0],k[1]
		outf.write('%s\t%s\n'%(k[0],str(k[1])))

#TODO: what should be the value?
def bz_feature_list(bz_folder,bzfile,outfile):
	feature_f=  open(bzfile,'r')
	of = open(outfile,'w')
	fdict = {}
	for line in feature_f:
		terms = line.strip().split('\t')
		if terms[0] != 'hours' and int(terms[1])>10:
			fdict[terms[0]] = []
	feature_f.close()
	
	files = os.listdir(bz_folder)
	for f in files:
		af = open(os.path.join(bz_folder,f.strip()),'r')
		for line in af:
			terms = line.lower().strip().split('::')
			key = terms[0]
			value = terms[1]
			if fdict.has_key(key):
				ans = value.split(',')
				for a in ans:
					if a.strip() in fdict[key]:
						pass
					else:
						fdict[key].append(a.strip())
	i = 0 
	for k,vs in fdict.items():
		if len(vs) == 2:	
			of.write('%s::%s=%i:%i\n'%(k,vs[0],i,0))
			of.write('%s::%s=%i:%i\n'%(k,vs[1],i,1))
			i += 1 
		else:
			for v in vs:
				of.write('%s::%s=%i:%i\n'%(k,v,i,1))
				i += 1	

def place_feature_matrix(bz_folder):
	data_dir = '/home/jane/workspace/Research/groupevents_dataprocess/'
	place_files = os.listdir(bz_folder)					
	row_of = open(data_dir+'row_name.txt','w')
	feature_f = open(data_dir+'feature_dict.txt','r')
	feature_of = open(data_dir+'feature_matrix.txt','w')
	features = {}
	for line in feature_f:
		terms = line.strip().split('=')
		features[terms[0].strip()] =	terms[1].strip()
						
	feature_num = 41
	for place in place_files:
		f = open(os.path.join(bz_folder,place.strip()),'r')
		row_of.write(place.strip()+'\n')
		print place.strip()
		score = yelp.objects.get(id=place.strip()).rating
		print score
		f_feature_v = [0.0]*42
		for line in f:
			l = line.lower().strip()
			if features.has_key(l):
				print l
				pos = features[l].split(':')
				print pos[0], pos[1]
				f_feature_v[int(pos[0])] = float(pos[1])
		f_feature_v[41] = float(score)
		feature_of.write(','.join(str(x) for x in f_feature_v)+'\n')
	
			

#bz_feature_list('yelp_bz_info','bzinfo_requence.txt','feature_dict.txt')
#get_bz_info_frequence('yelp_bz_info')					
#parse_bussiness_info('yelp_html','yelp_bz_info')
#parse_one_bussiness_info('yelp_html/1')
#store_yelp_html_pages('yelp_id_url.txt')
#select_restaurants('yelp_id_url.txt')

