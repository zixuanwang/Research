data = load('../recommendation_input/eid_iid_fuid_fvote_user5.txt');
for i = 1:19
    filename = strcat('../recommendation_input/eid_iid_fuid_fvote_user',str(i));
	filename = load('../recommendation_input/eid_iid_fuid_fvote_uid_vote_all.txt')
	data = load(filename);
    q = influence_model_per_user(uid,data);

end 
