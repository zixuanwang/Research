data_folder = './'
instance_folder= 'user_instance_existingvote/'
of = open('../user_instance_existingvote/uid_itemfeature_poscnt_negcnt_vote.txt','w')
feature_f = open('../recommendation_input/place_bzinfo_feature_matrix.txt','r')
features = feature_f.readlines()
	
feature_f.close()
	

instance_f = open('../matlab_scripts/output/serialize_fullinstance_byuser_withexistingvote_count.txt','r')
for line in instance_f:
	terms = line.strip().split('\t')
	print terms
	eid = terms[0]
	iid = terms[1]
	uid = terms[2]
	vote = terms[3]
	poscnt = terms[4]
	negcnt = terms[5]
	item_feature = features[int(iid)-1].strip()
	print item_feature
	of.write(uid+','+item_feature+','+poscnt+','+negcnt+','+vote+'\n')

instance_f.close()
of.close()

		
	
	

