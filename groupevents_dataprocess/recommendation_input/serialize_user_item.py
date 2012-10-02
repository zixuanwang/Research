
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
			realiid = eventDict[iid]
		else:
			print 'item %s does not exist!!'%iid

		of.write(str(realeid)+'\t'+str(realiid)+'\n')

seralizeEvent2()
#seralizeEvent3()

#seralizeUser()
#seralizeItem()
