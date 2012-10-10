data_folder = './'
instance_folder= 'user_instance_firstvote/'
of = open('../user_instance_firstvote/uid_itemfeature_vote.txt','w')
feature_f = open('../recommendation_input/place_bzinfo_feature_matrix.txt','r')
features = feature_f.readlines()
	
feature_f.close()

instance_f = open('../serialize_firstvote_eid_iid_uid_vote.txt','r')
for line in instance_f:
	terms = line.strip().split('\t')
	print terms
	eid = terms[0]
	iid = terms[1]
	uid = terms[2]
	vote = terms[3]
	item_feature = features[int(iid)-1].strip()
	print item_feature
	of.write(uid+','+item_feature+','+vote+'\n')

instance_f.close()
of.close()

		
	
	

