import os

def item_only():
	dirfolder = 'user_instance/'
	fs = os.listdir(dirfolder)
	of = open('user_instances.arff','w')
	of.write('@RELATION item_feature_all_user\n')
	of.write('@ATTRIBUTE user_id \t NUMERIC\n')
	n_features = 42
	for i in range(n_features):
		attr = '@ATTRIBUTE feature_'+str(i) + '\t NUMERIC'
		of.write(attr+'\n')

	of.write('@ATTRIBUTE class \t {1,-1}\n')
	of.write('@DATA\n')

	for fl in fs:
		print fl
		filename = dirfolder+fl.strip()
		f = open(filename,'r')
		for line in f:
			l = line.strip()
			of.write(str(fl.strip()) + ','+l+'\n')
		f.close()

	of.close()

def item_user():
	dirfolder = 'user_instance_plusmember_presence/'
	fs = os.listdir(dirfolder)
	of = open('user_instances_plusmember_presence.arff','w')
	of.write('@RELATION item_feature_user_presence_all_user\n')
	of.write('@ATTRIBUTE user_id \t NUMERIC\n')
	n_features = 62
	for i in range(n_features):
		attr = '@ATTRIBUTE feature_'+str(i) + '\t NUMERIC'
		of.write(attr+'\n')

	of.write('@ATTRIBUTE class \t {1,-1}\n')
	of.write('@DATA\n')

	for fl in fs:
		uid = fl.split('.')[0]
		print uid 
		filename = dirfolder+fl.strip()
		f = open(filename,'r')
		for line in f:
			l = line.strip()
			of.write(str(uid) + ','+l+'\n')
		f.close()

	of.close()

item_user()
