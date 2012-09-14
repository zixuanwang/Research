from myevents.models import *
from myevents.views import *

data_folder = '/home/jane/workspace/Research/groupevents_dataprocess/'
instance_folder= 'user_instance_withmember/'

#build_X_OnlyUser('full_instance_per_user.txt')
# instance file: eid, uid, iid, vote, date
def build_X_OnlyUser(instance_filename):
	instance_f = open(data_folder+instance_filename,'r')
	of = open('uid_iid_isadmin_31members.txt','w')
	for line in instance_f:
		terms = line.strip().split('\t')
		eid = terms[0]
		uid = terms[1]
		iid = terms[2]
		y = terms[3]

		print eid,uid,iid,y
		is_admin = 0
		n_all_user=31
		member_presence = [0]*n_all_user
		members = event_user.objects.filter(event_id = eid)
		for m in members:
			if int(uid) == int(m.user_id) and m.role=='admin':
				is_admin = 1
			# index starts with 0 for python list
			member_presence[int(m.user_id)-1] = 1
	 	
		#remove the self presence, otherwise it's full 1 column. no meaning.	
		presence_feature = ','.join(str(x) for x in member_presence)
		of.write(uid+','+iid+','+str(is_admin)+','+presence_feature+','+y+'\n')


#uid_iid_isadmin_19member.txt: instance_filename, is processed and contains uid, iid, is_admin, 19 member presence, vote
#row_name.txt: row_name_filename, has the item id correpsonding to each line in feature_filename
def build_X_withUser(row_name_filename, feature_filename,instance_filename):
	row_f = open(data_folder+row_name_filename,'r')
	rows= row_f.readlines()
	
	feature_f = open(data_folder+feature_filename,'r')
	features = feature_f.readlines()
	feature_dict = {}	
	if len(rows) != len(features):
		print 'row name does not match feature row!'
		return
	else:
		nfeature = len(rows)
		for i in range(nfeature):
			#print rows[i], features[i]
			feature_dict[rows[i].strip()] = features[i].strip()	
	
	feature_f.close()
	row_f.close()

	inactive_user = []
	inactive_u = user.objects.filter(is_active=False)|user.objects.filter(is_registered=False)
	for u in inactive_u :
		inactive_user.append(int(u.id))
	
	instance_f = open(data_folder+instance_filename,'r')
	user_instance = {}
	for line in instance_f:
		terms = line.strip().split(',')
		n_terms = len(terms)
		uid = terms[0]
		iid = terms[1]
	 
	 	right_feature = ','.join(terms[2:n_terms])
		if user_instance.has_key(uid):
			user_instance[uid].append(feature_dict[iid]+','+right_feature+'\n')
		else:
			user_instance[uid] = []
			user_instance[uid].append(feature_dict[iid]+','+right_feature+'\n')

	for k,vs in user_instance.items():
		instance_of = open(data_folder+instance_folder+k+'.dat','w')
		for v in vs:
			instance_of.write(v)
		instance_of.close()

#build_X_withUser('row_name.txt','place_bzinfo_feature_matrix.txt','uid_iid_isadmin_19member.txt')
