
% 11/15/2012

% first 4 weeks as training 
% last week as testing

% use the trained model from previous step ??? 
% or train the model from the first 4 weeks training set

% use the saved pj and pu 
% predict pui and pGi 
% rank items, compare with ground truth 


%##################################################
% prepare the data: eid, iid, uid, vote
data = load('../recommendation_input/serialize_eid_iid_uid_vote_dateunix.txt');
alldata = data(:,1:4);
n_events = length(unique(alldata(:,1)));
n_samples = length(alldata);
n_train_samples = round(0.8*n_samples);
n_test_samples = n_samples-n_train_samples+1;
test_data=alldata(n_train_samples+1:n_samples,:);
%##################################################
% load parameters
%
learn_pj = dlmread('output/cvx_cv_influence_pj_alluser.dat');

% n_items * n_users
learn_qui = dlmread('output/cvx_cv_predict_pui_alluser.dat');
n_items = size(learn_qui,1);

%##################################################
groundtruth = load('../recommendation_input/allserialized_event_item_vote.txt');

%##################################################
test_event_ids = unique(test_data(:,1));
n_test_events = length(test_event_ids);

avg_matches = zeros(n_test_events,1);
min_matches = zeros(n_test_events,1);
max_matches = zeros(n_test_events,1);
con_matches = zeros(n_test_events,1);
lcon_matches = zeros(n_test_events,1);
inf_matches = zeros(n_test_events,1);
n_valid_events = 0;
% for event in test_data
for j=1:n_test_events 
   % get the group subcript. 
   eid = test_event_ids(j);
   G = unique(test_data(test_data(:,1)==eid,3));
   size_group = length(G);
   
   % AVERAGE  
   avg_pi = mean(learn_qui(:,G),2);
  
   % MAX 
   max_pi = max(learn_qui(:,G),[],2);

   % MIN 
   min_pi = min(learn_qui(:,G),[],2);
   
   % CONsensus 
   con_pi = consensus(learn_qui(:,G));
   
   % l_consensus
   lcon_pi = l_consensus(learn_qui(:,G));
   
   % influence 
   inf_pi = inf_consensus(G, learn_qui, learn_pj);
   
   % groundtruth  event_id, item_id, pos_vote, neg_vote, total_vote
   items = groundtruth(groundtruth(:,1)==eid,:);
   % consider the half top among these 6 items. 
   n_event_item = size(items,1);
   if n_event_item <3
      continue;
   else
      n_valid_events = n_valid_events+1;
      % EXIST THE BEST ONE? 
      K = ceil(size_group/2);
      avg_matches(j) = evaluate_existOne(avg_pi, K, items);
      max_matches(j) = evaluate_existOne(max_pi, K, items);
      min_matches(j) = evaluate_existOne(min_pi, K, items);
      con_matches(j) = evaluate_existOne(con_pi, K, items);
      lcon_matches(j) = evaluate_existOne(lcon_pi, K, items);
      inf_matches(j) =  evaluate_existOne(inf_pi, K, items);
   end
end
   fprintf('average  hit ratio: %f\n',sum(avg_matches>0)/n_valid_events);
   fprintf('max  hit ratio: %f\n',sum(max_matches>0)/n_valid_events);
   fprintf('min  hit ratio: %f\n',sum(min_matches>0)/n_valid_events);
   fprintf('consensus  hit ratio: %f\n',sum(con_matches>0)/n_valid_events);
   fprintf('k-consensus hit ratio: %f\n',sum(lcon_matches>0)/n_valid_events);
   fprintf('influence hit ratio: %f\n',sum(inf_matches>0)/n_valid_events);

   fprintf('average  matches per event: %f\n',sum(avg_matches )/n_valid_events);
   fprintf('max  matches per event: %f\n',sum(max_matches )/n_valid_events);
   fprintf('min  matches per event: %f\n',sum(min_matches )/n_valid_events);
   fprintf('consensus  matches per event: %f\n',sum(con_matches )/n_valid_events);
   fprintf('k-consensus matches per event: %f\n',sum(lcon_matches )/n_valid_events);
   fprintf('influence matches per event: %f\n',sum(inf_matches )/n_valid_events);

