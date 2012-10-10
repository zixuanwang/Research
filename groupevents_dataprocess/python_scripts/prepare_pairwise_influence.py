import unicodedata
from numpy  import *
import MySQLdb
db = MySQLdb.connect(host='localhost',user='root',passwd='fighting123',db='groupevents_exp')
c = db.cursor()

n_user = 19

A = zeros((n_user,n_user))

for i in range(n_user):
	uid = i+1; 
	for j in range(n_user):
		vid = j+1
		if vid!=uid:
			query = 'select p1.event_id, p1.item_id, p1.vote, p2.vote from(select event_id, item_id, vote, unixdate from serialize_poll as p where p.user_id= '+str(uid)+ ') p1, (select event_id, item_id,vote, unixdate from serialize_poll as p where p.user_id ='+str(vid)+')p2 where p1.event_id = p2.event_id and p1.item_id = p2.item_id  and p1.vote = p2.vote and p1.unixdate < p2.unixdate'
			print query
			c.execute(query)
			rows = c.fetchall()
			A[i][j]=len(rows)
c.close()

of = open('pairwise_influence_value.txt','w')
for i in range(n_user):
	print A[i] 
	thisline = ','.join(str(x) for x in A[i])
	of.write(thisline+'\n')

of.close()





