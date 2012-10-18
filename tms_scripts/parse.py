import xml.etree.ElementTree as et
import unicodedata
import pprint
import simplejson
import MySQLdb

pp = pprint.PrettyPrinter()
conn = MySQLdb.connect (host = "localhost",user = "root", passwd = "fighting123", db = "mymovies")
cursor = conn.cursor ()

def create_dbtable():
	query = 'create table if not exists movie(id int not null primary key auto_increment, mov_id varchar(255) not null , title text, genre text, description text, release_date int, img_id int)'
	cursor.execute(query)

	query = 'create table if not exists theatre(id int not null primary key auto_increment, thid varchar(255), name text, street text,  city text,  state varchar(255),country varchar(255), postcode varchar(255), telephone varchar(255), url text, longitude varchar(255), latitude varchar(255))'
	cursor.execute(query)

	query = 'create table if not exists schedule(id int  not null primary key auto_increment, mov_id varchar(255), thid varchar(255), date varchar(255), times text)'
	cursor.execute(query)


def parse_schedule():

	data = open('../tms_live_data/on_usa_mov_schedules_20121018.xml').read()
	root = et.fromstring(data)
	entry_list = []
	count = 0

	for eachsch in root.findall(".//schedule"):
		for eve in eachsch.findall('./event'):
			timings = [x.text for x in eve.findall('.//time')]
			thid = eachsch.attrib['theatreId'] 
			date = eve.attrib['date']
			mov_id = eve.attrib['TMSId']
			if timings:
				show_time = ', '.join(timings)
			else:
				show_time = 'NULL'
			print mov_id, thid, date, show_time 
			#query = 'insert into schedule(mov_id, thid, date, times) values("%s",%s,"%s","%s")'%(mov_id,thid,date,show_time)
			query = 'insert into myevents_schedule(mov_id, thid, date, showtimes) values("%s",%s,"%s","%s")'%(mov_id,thid,date,show_time)
			print query
			cursor.execute(query)
			count+=1

	print "total schedules :: ", count
	return


def parse_theatres():

	data = open('../tms_live_data/on_usa_mov_sources_20121018.xml').read()
	root = et.fromstring(data)
	
	tdt = {}
	tdata = []

	for eachth in root.findall(".//theatre"):
		thid = eachth.attrib['theatreId']
		fthid = eachth.attrib['aaCode']
		tname = eachth.findall('./name')[0].text.encode('ascii', 'ignore')
		street = eachth.findall('./address//street1')[0].text.encode('ascii', 'ignore') if eachth.findall('./address//street1') else 'NULL'
		city = eachth.findall('./address//city')[0].text.encode('ascii', 'ignore') if eachth.findall('./address//city') else 'NULL'
		state = eachth.findall('./address//state')[0].text.encode('ascii', 'ignore') if eachth.findall('./address//state') else 'NULL'
		country = eachth.findall('./address//country')[0].text.encode('ascii', 'ignore') if eachth.findall('./address//country') else 'NULL'
		zipcode = eachth.findall('./address//postalCode')[0].text.encode('ascii', 'ignore') if eachth.findall('./address//postalCode') else 'NULL'
		url = eachth.findall('./URL')[0].text.encode('ascii', 'ignore') if eachth.findall('./URL') else 'NULL'
		telephone = eachth.findall('./telephone')[0].text.encode('ascii', 'ignore') if eachth.findall('./telephone') else 'NULL'
		lat = eachth.findall('./latitude')[0].text.encode('ascii', 'ignore') if eachth.findall('./latitude') else 'NULL'
		lon = eachth.findall('./longitude')[0].text.encode('ascii', 'ignore') if eachth.findall('./longitude') else 'NULL'
		print thid, tname, street, city, state, country, zipcode, url, telephone, lat, lon
	
		query = 'insert into myevents_theatre(thid, fthid, name, street, city, state, country, postcode, url,telephone,longitude,latitude) values(%s, "%s", "%s", "%s", "%s", "%s", "%s","%s","%s","%s",%s,%s)'%(thid,fthid,tname,street,city,state,country,zipcode,url,telephone,lon,lat,)
		print query
		cursor.execute(query)
	return
	
def parse_movies():

	data = open('../tms_live_data/on_usa_mov_programs_20121018.xml').read()
	root = et.fromstring(data)
	count = 0
	mdt = {}

	for eachprog in root.findall(".//program"):
		genre = []
		mov_id = eachprog.attrib['TMSId']
		img_id = eachprog.attrib['altFilmId']
		title = eachprog.findall('./titles//title')[0].text.encode('ascii','ignore')
		d = eachprog.findall('./descriptions//desc')
		if d:
			description = d[0].text.encode('ascii', 'ignore')
		else:
			description = ''
		g = eachprog.findall('./genres//genre')
		if g:
			for i in g:
				genre.append(i.text.encode('ascii', 'ignore'))
		else:
			genre = []
		rel = eachprog.findall('./movieInfo/releases/release')
		if rel:
			release_date = rel[0].attrib.get('date')
		else:
			release_date = ''
		prog_type = eachprog.findall('./progType')[0].text
		
		if prog_type == 'Feature Film' and genre:
			genres = ','.join(genre)
			#print mov_id, title, genres, release_date, description, img_id
			description = description.replace("'","\\\'")
			title = title.replace("'","\\\'")
			description = description.replace('"','\\\"')
			title = title.replace('"','\\\"')
			query = 'insert into myevents_movie(mov_id, title,genre, release_date, description, img_id) values("%s", "%s", "%s", %s, "%s", %s)'%(mov_id,title,genres,release_date,description, img_id)
			print query
			cursor.execute(query)

			count+=1
	print count
	print 'Number of rows in database', cursor.rowcount
	
	return 


if __name__=='__main__':

#	parse_movies()
#	parse_theatres()
	parse_schedule()

#	create_dbtable()

