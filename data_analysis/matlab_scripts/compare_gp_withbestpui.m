
% 11/15/2012

% first 4 weeks as training 
% last week as testing

% use the trained model from previous step ??? 
% or train the model from the first 4 weeks training set

% use the saved pj and pu 
% predict pui and pGi 
% rank items, compare with ground truth 


%#########################
% prepare the data: eid, iid, uid, vote
data = load('../recommendation_input/serialize_eid_iid_uid_vote_dateunix.txt');
alldata = data(:,1:4);
n_events = length(unique(alldata(:,1)));
n_samples = length(alldata);
n_train_samples = round(0.8*n_samples);
n_test_samples = n_samples-n_train_samples+1;
test_data=alldata(n_train_samples+1:n_samples,:);
 
%test_data = load('recommendation_input/test_gp_data.txt');

% load parameters
% n_items * n_users
learn_pj = dlmread('output/cvx_cv_influence_pj_alluser.dat');
learn_qui = dlmread('output/cvx_cv_predict_pui_alluser.dat');

%#########################

test_event_ids = unique(test_data(:,1));
n_test_events = length(test_event_ids);
% for event in test_data
for j=1:n_test_events 
   % get the group subcript. 
   eid = test_event_ids(j);
   G = test_data(test_data(1,:)==eid,3);
    
   % AVERAGE  
   avg_pi = mean(learn_qui(:,G),1) ;
   
   % MAX 
   max_pi = max(learn_qui(:,G),1);
   
   % MIN 
   min_pi = min(learn_qui(:,G),1);
   
   % CONsensus 
   con_pi = consensus(learn_qui,G);
   
   % l_consensus
   lcon_pi = l_consensus(learn_qui,G);
   
end
