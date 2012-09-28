% 9/26/2012 JINYUN
% for each event: predict the ranking of the items
% 
% for item in the event:
%   for user in the event:     
%       predict vote(user,item)
%   group_vote(i) = sum(vote(user,item))    
% rank group_vote 
% measure whether the most voted item is correctly found. 
%
% feature_type: item_only, item_user
% method: dynamic, aggregate
% measure: top1, top_k,top_half

function n_matched = compare_group_recommendation_allitems(feature_type,method,measure,measure_size)
    
    % event_id, item_id, pos_vote, neg_vote, total_votes
    all_events = load('../recommendation_input/event_item_vote.txt');
    % event_id, user_id
    all_groups = load('../recommendation_input/event_user.txt');

    % one row is a feature vector for one item
    item_features = load('../recommendation_input/place_bzinfo_feature_matrix.txt');
    % associate vector to item_features.  one row is the item id.
    item_features_ids = load('../recommendation_input/place_feature_row_id.txt');
    
    
    if strcmp(feature_type,'item_only')
        % one column is a weight vector for a user
        weight_user =dlmread('../recommendation_input/weight_itemonly.dat');
    elseif strcmp(feature_type, 'item_user')
        % one column is a weight vector for a user if trained by
        % item_user features.
        weight_user= load('../recommendation_input/weight_vector.dat');
    else
        fprintf('wrong feature type');
        exit(-1);
    end
    % associate vector for weight vector, one row is a user id: not
    % consecutive
    weight_userid = load('../recommendation_input/weight_userid.dat');
    
    % the maximal value of user id. 
    n_users = 31;
    % active user id. 
    active_users = load('../recommendation_input/active_user_id.txt');
    n_active_users = size(active_users,1);
    
    n_matched=0;
    n_events = 0;
    for i=1:280 
        a_event = all_events(all_events(:,1)==i,:);
        if isempty(a_event)
            continue;
        end
        n_events = n_events +1;
        
        % get the user id of this group/event
        the_group = all_groups(all_groups(:,1)==i,:);
        users = the_group(:,2);
        % number of users in the event 
        n_group_size = length(users);
        
        % number of voted items for this group
        n_voted_items = size(a_event,1);
        % number of all items. 
        n_all_items = length(item_features_ids);

        % sort item id by pos votes in ascending order
        %A = sortrows(a_event,3);
        %pos_votes = A(:,3);
        %neg_votes = A(:,4);
        pos_votes = a_event(:,3);
        event_item_ids = a_event(:,2);
        % get the item ids of the event. 
        %event_item_ids = A(:,2);
       
        % predicted results 
        pred_pos_votes = zeros(n_all_items,1);
        pred_neg_votes = zeros(n_all_items,1);
        
        % select the theta for users in this event. 
        [ismem index] = ismember(users,weight_userid);
        theta = weight_user(:,index); 
         
        for k=1:n_all_items 
            % kth item feature's id: kth line in item_feature_ids 
            item_feature = item_features(k,:);
            % each user observe the same item feature
            item_matrix = repmat(item_feature, n_group_size,1);
            
           	% build the feature vector x 
            if strcmp(feature_type,'item_user')
                % build the vector for user presence features
                full_user_feature = zeros(n_users,1);
                full_user_feature(users) = 1; 
                user_feature = full_user_feature(active_users);
                % x : m*n  where m is the size of the all active users, n is the size of the
                % feature, one row is the feature for one user
                user_matrix = repmat(user_feature', n_group_size,1);
                is_admin = the_group(:,3);
                x = [item_matrix, user_matrix, is_admin];
            elseif strcmp(feature_type,'item_only')
                x = item_matrix;
            end
            
           % prediction
           pred = zeros(n_group_size,1);
           for u=1:n_group_size
               pred(u) = Logistic(theta(1,u) + x(u,:)*theta(2:end,u));  
           end
        
            if strcmp(method, 'dynamic')
                d = length(pred);
                threshold = round(d/2);
                % the probability that this item will be selected by at least k
                % people
                fkd = compute_fkd(pred,threshold,d);
                pred_neg_votes(k) = fkd;
                pred_pos_votes(k) = 1- fkd;
            elseif strcmp(method,'aggregate')
                pred_pos_votes(k) = sum(pred);
                pred_neg_votes(k) = sum(pred);
            else
                fprintf('wrong method!');
                exit(-1);
            end
        end % end of compute the pred score for items
  
        if strcmp(measure,'top1')
            pos_matched = is_topk_matched(pred_pos_votes,item_features_ids,pos_votes,event_item_ids,1);
        elseif strcmp(measure, 'top_half')
             pos_matched = is_topk_matched(pred_pos_votes,item_features_ids,pos_votes,event_item_ids,round(length(pos_votes)/2)); 
         elseif strcmp(measure, 'top_k')
             pos_matched = is_topk_matched(pred_pos_votes,item_features_ids,pos_votes,event_item_ids,measure_size); 
        else
            fprint('wrong type of measurement');
            exit(-1);
        end
         
        n_matched = n_matched + pos_matched;
        
    end % end the loop for all events
    
     
    if strcmp(measure,'top1')
        fprintf(' out of %d event, average value of top 1 precision: %f\n',n_events,n_matched/n_events);
    elseif strcmp(measure, 'top_half')
        fprintf('out of %d event, average value of top half precisions: %f\n', n_events,n_matched/n_events);
    elseif strcmp(measure,'top_k')
       fprintf('out of %d event, average value of top %d precisions: %f\n', n_events,measure_size,n_matched/n_events);
    end
end