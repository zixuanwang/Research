f = open('../finalChoicename.txt','r')
import unicodedata
import MySQLdb
db = MySQLdb.connect(host='localhost',user='root',passwd='fighting123',db='groupevents_exp')
c = db.cursor()

of=open('../item_name_id.txt','w')
for line in f:
	terms = line.strip().split('\t')
	if len(terms)==2:
		eid = terms[0]
		place = terms[1]
		#print place
		if place=='\N': 
			#print 'place is null!!!'
			continue
		else:
			name = place.strip().split(',')[0].strip()
			if type(name) is unicode:
				tname = unicodedata.normalize('NFKD',name).encode('ascii','ignore') 
			else:
				tname = name
			name = tname.replace("'","\\\'")
			query = "select id  from myevents_item where name like '%"+name+"%'"
			print query
			c.execute(query)
			
			row = c.fetchone()
			if row:
				print row[0]
				of.write(eid+'\t'+str(row[0])+'\n')
			else:
				print 'ERROR! for %s'%name 
				of.write(eid+'\t'+name+'\n')
