import unicodedata
import MySQLdb
db = MySQLdb.connect(host='localhost',user='root',passwd='fighting123',db='groupevents_exp')
c = db.cursor()





n_user = 19
query = 'select p1.event_id, p1.pickid, p1.vote, p2.vote from(select event_id, pickid, vote, date from serialize_poll as p, myevents_choice as  c where p.choice_id = c.id and p.user_id= '+uid+ ') p1, (select event_id,pickid,vote, date from serialize_poll as p, myevents_choice as c where p.choice_id = c.id and p.user_id ='+vid+')p2 where p1.event_id = p2.event_id and p1.pickid = p2.pickid and p1.date < p2.date'

A = []

for i in range(n_user):
	uid = i+1; 
	A(i) = [0] * n_user;




