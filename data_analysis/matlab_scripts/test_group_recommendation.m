% 9/17/2012 JINYUN
% for each event: predict the ranking of the items
% 
% for item in the event:
%   for user in the event:     
%       predict vote(user,item)
%   group_vote(i) = sum(vote(user,item))    
% rank group_vote 
% measure whether the most voted item is correctly found. 

all_events = load('../recommendation_input/event_item_vote.txt');
all_groups = load('../recommendation_input/event_user.txt');

% one row is a feature vector for one item
item_features = load('../recommendation_input/place_bzinfo_feature_matrix.txt');
item_features_ids = load('../recommendation_input/place_feature_row_id.txt');

% one column is a weight vector for a user
all_weights = dlmread('../recommendation_input/weight_vector.dat');
item_weights = dlmread('../recommendation_input/weight_itemonly.dat');
weight_userid = load('../recommendation_input/weight_userid.dat');

% the max id of user
n_users = 31;
active_users = load('../recommendation_input/active_user_id.txt');
n_matched=0;
n_events = 0;
for i=1:280 
    a_event = all_events(all_events(:,1)==i,:);
    if isempty(a_event)
        continue;
    end
    n_events = n_events +1;
    
    the_group = all_groups(all_groups(:,1)==i,:);
    users = the_group(:,2);
    items = a_event(:,2);
    n_items = length(items);
    n_groupsize = length(users);
    
    pos_votes = a_event(:,3);
    neg_votes = a_event(:,4);
    pred_pos_votes = zeros(n_items,1);
    pred_neg_votes = zeros(n_items,1);
    for k=1:n_items
        ind = find( item_features_ids==items(k)); 
        item_feature = item_features(ind,:);
        item_matrix = repmat(item_feature, n_groupsize,1);
      
        % build the vector for user presence features
        full_user_feature = zeros(n_users,1);
        full_user_feature(users) = 1; 
        user_feature = full_user_feature(active_users);
        user_matrix = repmat(user_feature', n_groupsize,1);
        is_admin = the_group(:,3);
        
        % x : m*n  where m is the size of the group, n is the size of the
        % feature, one row is the feature for one user
        x = [item_matrix, user_matrix, is_admin];
        
        % user weight vector
        [ismem index] = ismember(users,weight_userid);
        theta = all_weights(:,index);
        
        pred = zeros(n_groupsize,1);
        for u=1:n_groupsize
            pred(u) = Logistic(theta(1,u) + x(u,:)*theta(2:end,u));  
        end
        
        pred_pos_votes(k) = sum(pred>=0.5);
        pred_neg_votes(k) = sum(pred<0.5);
    end
    
    % compute nDCG of pos vote prediction
    pos_matched = is_maximum_matched(pred_pos_votes,pos_votes);
    n_matched =n_matched+pos_matched;

end
fprintf(' out of %d event, number of maximum matches: %d\n',n_events,n_matched);



