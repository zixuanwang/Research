data_folder = './'
instance_folder= 'user_instance/'
def build_X(row_name_filename, feature_filename,instance_filename):
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
			print rows[i], features[i]
			feature_dict[rows[i].strip()] = features[i].strip()	
	
	feature_f.close()
	row_f.close()

	instance_f = open(data_folder+instance_filename,'r')
	user_instance = {}
	for line in instance_f:
		terms = line.strip().split('\t')
		uid = terms[0]
		iid = terms[1]
		y = terms[2]

		print uid,iid,y
		if user_instance.has_key(uid):
			user_instance[uid].append(feature_dict[iid]+','+y+'\n')
		else:
			user_instance[uid] = []
			user_instance[uid].append(feature_dict[iid]+','+y+'\n')

	for k,vs in user_instance.items():
		instance_of = open(data_folder+instance_folder+k,'w')
		for v in vs:
			instance_of.write(v)
		instance_of.close()

build_X('row_name.txt','place_bzinfo_feature_matrix.txt','instance_per_user.txt')
