

pu = 0.5541

f = open('../recommendation_input/eid_iid_fuid_fvote_user5_user5vote.txt','r')

posDict = {}
negDict = {}


for line in f:
	terms = line.strip().split('\t')
	eid = terms[0]
	iid = terms[1] 
	fuid = terms[2]
	fvote = terms[3] 
	uid =  terms[4] 
	vote = terms[5] 

	print terms

	if int(fvote) == 1:
		if int(vote) == 1 : 
			if posDict.has_key(eid):
				posDict[eid].append(fuid)
			else:
				posDict[eid]=[]
				posDict[eid].append(fuid)
		elif int(vote)==-1:
			if negDict.has_key(eid):
				negDict[eid].append(fuid)
			else:
				negDict[eid]= [] 
				negDict[eid].append(fuid)

f.close()

i=0
r_str = []
l_equation = []
for (key,value) in posDict.items():
	print key
	prods = '*'.join(['(1-p('+v+'))'  for v in value])
	r_str.append( 'r('+str(i) + ') = '+prods +'*(1-'+str(pu)+')')
	print prods 
	i += 1
	l_equation.append('(1-'+prods +'*(1-'+str(pu)+'))')
	# get the p_ui 
i=0		
r_equation = []

bDict = {}
for i in 1:19
	

for (key,value) in negDict.items():
	print key,','.join(value)
	prods = '*'.join(['(1-p('+v+'))'  for v in value])
	r_equation.append(prods)

of = open('user5_cvx_equation.txt','w')
of.write('*'.join(l_equation)+'*'+'*'.join(r_equation)+'\n')
of.close()
