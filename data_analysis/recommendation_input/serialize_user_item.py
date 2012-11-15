
f = open('active_user_id.txt')
userDict = {}
i = 1
for line in f:
	uid = line.strip()
	userDict[uid] = i
	i += 1
f.close()

itemDict = {}
f = open('place_feature_row_id.txt')
i = 1
for line in f:
	pid = line.strip()
	itemDict[pid] = i 
	i += 1
f.close()

f = open('valid_event_id.dat','r')
eventDict = {}
i = 1
for line in f:
	eventDict[line.strip()] = i
	i += 1
f.close()

def seralizeUser():
	f = open('event_user.txt','r')
	of = open('serialized_event_user.txt','w')
	for line in f:
		terms = line.strip().split('\t')
		eid = terms[0]
		uid = terms[1]
		role = terms[2]
		if userDict.has_key(uid):
			realuid = userDict[uid]
		else:
			print '%s does not exist!!'%uid
		of.write(eid+'\t'+str(realuid)+'\t'+role+'\n');
	f.close()
	of.close()

def seralizeItem():
	f = open('event_item_vote.txt','r')
	of = open('serialized_event_item_vote.txt','w')
	for line in f:
		terms = line.strip().split('\t')
		eid = terms[0]
		iid = terms[1]
		posvote = terms[2]
		negvote = terms[3]
		allvote = terms[4]
		if itemDict.has_key(iid):
			realiid = itemDict[iid]
		else:
			print '%s does not exist!!'%iid
		of.write(eid+'\t'+str(realiid)+'\t'+posvote+'\t'+negvote+'\t'+allvote+'\n');
	f.close()
	of.close()

def seralizeEvent():
	f = open('serialized_event_item_vote.txt','r')
	of = open('allserialized_event_item_vote.txt','w')

	for line in f:
		terms = line.strip().split('\t')
		eid = terms[0] 
		iid = terms[1]
		posvote = terms[2]
		negvote = terms[3]
		allvote = terms[4]
		if eventDict.has_key(eid):
			realeid = eventDict[eid]
			of.write(str(realeid)+'\t'+iid+'\t'+posvote+'\t'+negvote+'\t'+allvote+'\n')
		else:
			print '%s does not exist!!'%eid

def seralizeEvent2():
	f = open('serialized_event_user.txt','r')
	of = open('allserialized_event_user.txt','w')

	for line in f:
		terms = line.strip().split('\t')
		eid = terms[0] 
		uid = terms[1]
		role = terms[2]
		if eventDict.has_key(eid):
			realeid = eventDict[eid]
			of.write(str(realeid)+'\t'+uid+'\t'+role+'\n')
		else:
			print '%s does not exist!!'%eid

def seralizeEvent3():
	f = open('finalChoice_event_item.txt','r')
	of = open('allserialized_finalChoice_event_item.txt','w')

	for line in f:
		terms = line.strip().split('\t')
		eid = terms[0] 
		iid = terms[1]
		print eid,iid
		if eventDict.has_key(eid):
			realeid = eventDict[eid]
		else:
			print '%s does not exist!!'%eid
		if itemDict.has_key(iid):
			realiid = itemDict[iid]
		else:
			print 'item %s does not exist!!'%iid

		of.write(str(realeid)+'\t'+str(realiid)+'\n')


def seralizeVote():
	# eid, uid, iid, vote, datetime
	f = open('../full_instance_per_user.txt','r')

	of = open('allserialized_full_instance_per_user.txt','w')
	for line in f:
		terms = line.strip().split('\t')
		eid = terms[0]
		uid = terms[1]
		iid = terms[2]
		vote = terms[3]
		datetime = terms[4]

		if eventDict.has_key(eid):
			realeid = eventDict[eid]
			if itemDict.has_key(iid):
				realiid = itemDict[iid]
				if userDict.has_key(uid):
					realuid = userDict[uid]
					of.write(str(realeid)+'\t'+str(realuid)+'\t'+str(realiid)+'\t'+vote+'\t'+datetime+'\n')
				else:
					print 'the  user %s does not exist!! '%uid

			else:
				print 'the item %s does not exist!!'%iid
		else:
			print 'event %s does not exist!!'%eid

def seralizeAccuracy():
	f = open('../logit_itemonly_accuracy.txt','r')
	of = open('../serialized_logit_itemonly_accuracy.txt','w')
	for line in f:
		terms = line.strip().split('\t')
		print terms
		uid = terms[0]
		train = terms[1]
		test = terms[2]
		if userDict.has_key(uid):
			realuid = userDict[uid]
			of.write(str(realuid)+'\t'+train+'\t'+test+'\n')
		else:
			print 'the user %s does not exist ?'%uid
	f.close()
	of.close()

def seralizeAccuracy2():
	f = open('../logit_itemuser_accuracy.txt','r')
	of = open('../serialized_logit_itemuser_accuracy.txt','w')
	for line in f:
		terms = line.strip().split('\t')
		print terms
		uid = terms[0]
		train = terms[1]
		test = terms[2]
		if userDict.has_key(uid):
			realuid = userDict[uid]
			of.write(str(realuid)+'\t'+train+'\t'+test+'\n')
		else:
			print 'the user %s does not exist ?'%uid
	f.close()
	of.close()


def serializeFullInstance():
	f = open('../matlab_scripts/output/full_instance_orderby_user_withexistingvote_count.txt','r')
	of = open('../matlab_scripts/output/serialize_fullinstance_byuser_withexistingvote_count.txt','w')
	for line in f:
		print line
		terms = line.strip().split(',')
		eid = terms[0]
		iid = terms[1]
		uid = terms[2]
		vote = terms[3]
		poscnt = terms[4]
		negcnt = terms[5]
		if eventDict.has_key(eid):
			seid = str(eventDict[eid])
			if itemDict.has_key(iid):
				siid = str(itemDict[iid])
				if userDict.has_key(uid):
					suid = str(userDict[uid])
					of.write(seid+'\t'+siid+'\t'+suid+'\t'+vote+'\t'+poscnt+'\t'+negcnt+'\n')
				else:
					print '%s user does not exist'%uid
			else:
				print '%s item does not exist!'%iid
		else:
			print '%s event is not valid!'%eid 


def serializeFirstVote():
	f = open('../first_vote_eid_iid_uid_vote.txt','r')
	of = open('../serialize_firstvote_eid_iid_uid_vote.txt','w')
	for line in f:
		terms = line.strip().split('\t')
		eid = terms[0]
		iid = terms[1]
		uid = terms[2]
		vote = terms[3]
		
		if eventDict.has_key(eid):
			realeid = eventDict[eid]
			if itemDict.has_key(iid):
				realiid = itemDict[iid]
				if userDict.has_key(uid):
					realuid = userDict[uid]
					of.write(str(realeid)+'\t'+str(realiid)+'\t'+str(realuid)+'\t'+vote+'\n')
				else:
					print 'The user id %s doesnot exist'%uid
			else:
				print 'The item id %s does not exist'%iid
		else:
			print 'the event id %s does not exist'%eid
	f.close()
	of.close()

def serializeUnixDate():
	f = open('../eid_iid_uid_vote_dateunix.txt','r')
	of = open('serialize_eid_iid_uid_vote_dateunix.txt','w')
	for line in f:
		terms = line.strip().split('\t')
		eid = terms[0]
		iid = terms[1]
		uid = terms[2]
		vote = terms[3]
		date = terms[4]
		
		if eventDict.has_key(eid):
			realeid = eventDict[eid]
			if itemDict.has_key(iid):
				realiid = itemDict[iid]
				if userDict.has_key(uid):
					realuid = userDict[uid]
					of.write(str(realeid)+'\t'+str(realiid)+'\t'+str(realuid)+'\t'+vote+'\t'+date+'\n')
				else:
					print 'The user id %s doesnot exist'%uid
			else:
				print 'The item id %s does not exist'%iid
		else:
			print 'the event id %s does not exist'%eid
	f.close()
	of.close()


serializeUnixDate()
#serializeFirstVote()
#serializeFullInstance()
#seralizeAccuracy2()
#seralizeVote()
#seralizeEvent3()

#seralizeUser()
#seralizeItem()
