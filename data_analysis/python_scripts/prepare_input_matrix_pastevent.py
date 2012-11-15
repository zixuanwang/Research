data_folder = '../'
instance_folder= 'user_instance_pastevent/'
f = open('../recommendation_input/allserialized_finalChoice_event_item.txt','r')
finalChoiceDict = {}
for line in f :
	terms = line.strip().split('\t')
	finalChoiceDict[terms[0]] = terms[1]
f.close()

def get_lastEvent(eid,uid):
	f =  open('../recommendation_input/allserialized_event_user.txt','r')
	myeids = []
	for line in f:
		terms = line.strip().split('\t')
		user_id = terms[1]
		event_id = terms[0]
		if int(uid)==int(user_id):
			myeids.append(event_id)
	f.close()
	
	myeids_int = map(int,  myeids)
	myeids_int.sort()
	print myeids_int	
	if int(eid) in myeids_int:
		eididx =myeids_int.index(int(eid))
		if eididx==0:
			return None
		else:
			return str(myeids_int[eididx-1])
	else:
		print 'this eid %s does not belong to user %s'%(eid,uid)
	

def build_X():
	feature_f = open('../recommendation_input/place_bzinfo_feature_matrix.txt','r')
	i = 1
	feature_dict={}
	for line in feature_f:
		feature = line.strip()
		feature_dict[str(i)]=feature
		i = i+1
	feature_f.close()

	instance_f = open('../recommendation_input/allserialized_full_instance_per_user.txt','r')
	user_instance = {}
	for line in instance_f:
		terms = line.strip().split('\t')
		eid = terms[0]
		uid = terms[1]
		iid = terms[2]
		y = terms[3]
		print line.strip()

		last_eid = get_lastEvent(eid,uid)
		# get past finalChoice
		if last_eid:
			print 'last eid for event %s for user %s is %s'%(eid,uid,last_eid)
			if finalChoiceDict.has_key(last_eid):
				last_iid = finalChoiceDict[last_eid]
				#print uid,iid,last_iid,y

				if user_instance.has_key(uid):
					user_instance[uid].append(feature_dict[iid]+','+feature_dict[last_iid]+','+y+'\n')
				else:
					user_instance[uid] = []
					user_instance[uid].append(feature_dict[iid]+','+feature_dict[last_iid]+','+y+'\n')
			else:
				print '%s event does not have final choice '%last_eid
		else:
			print '%s event does not have past event '%eid
	for k,vs in user_instance.items():
		instance_of = open(data_folder+instance_folder+k,'w')
		for v in vs:
			instance_of.write(v)
		instance_of.close()


build_X()
