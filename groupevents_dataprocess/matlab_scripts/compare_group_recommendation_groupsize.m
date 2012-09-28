% 9/20/2012 JINYUN
% 9/26/2012 update
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

function n_matched = compare_group_recommendation_groupsize(feature_type,method,measure,measure_size,group_size)
    all_events = load('../recommendation_input/event_item_vote.txt');
    all_groups = load('../recommendation_input/event_user.txt');

    % one row is a feature vector for one item
    item_features = load('../recommendation_input/place_bzinfo_feature_matrix.txt');
    item_features_ids = load('../recommendation_input/place_feature_row_id.txt');
    
    % one column is a weight vector for a user
    if strcmp(feature_type,'item_only')
        weight_user =dlmread('../recommendation_input/weight_itemonly.dat');
    elseif strcmp(feature_type, 'item_user')
        weight_user= load('../recommendation_input/weight_vector.dat');
    else
        fprintf('wrong feature type');
        exit(0);
    end
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
        the_group = all_groups(all_groups(:,1)==i,:);
        users = the_group(:,2);
        n_groupsize = length(users);
        if n_groupsize ~= group_size
            continue;
        end
        n_events = n_events +1;
        
        item_ids = a_event(:,2);
        n_items = length(item_ids);
    
        pos_votes = a_event(:,3);
        neg_votes = a_event(:,4);
        pred_pos_votes = zeros(n_items,1);
        pred_neg_votes = zeros(n_items,1);
       
        % user weight vectoer
        [ismem index] = ismember(users,weight_userid);
        theta = weight_user(:,index);
        
        for k=1:n_items
            ind = find(item_features_ids==item_ids(k)); 
            item_feature = item_features(ind,:);
            item_matrix = repmat(item_feature, n_groupsize,1);
		
            if strcmp(feature_type,'item_user')
                % build the vector for user presence features
                full_user_feature = zeros(n_users,1);
                full_user_feature(users) = 1; 
                user_feature = full_user_feature(active_users);
                % x : m*n  where m is the size of the group, n is the size of the
                % feature, one row is the feature for one user
                user_matrix = repmat(user_feature', n_groupsize,1);
                is_admin = the_group(:,3);
                x = [item_matrix, user_matrix, is_admin];
            elseif strcmp(feature_type,'item_only')
                x = item_matrix;
            end
                 
           % prediction
           pred = zeros(n_groupsize,1);
           for u=1:n_groupsize
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
                pred_pos_votes(k) = sum(pred>=0.5);
                pred_neg_votes(k) = sum(pred<0.5);
            else
                fprintf('wrong method!');
                exit(0);
            end
        end
  
        if strcmp(measure,'top1')
            % compute  of pos vote prediction
            pos_matched = is_topk_matched(pred_pos_votes,item_ids,pos_votes,item_ids,1);  
        elseif strcmp(measure, 'top_half')
            pos_matched = is_topk_matched(pred_pos_votes,item_ids,pos_votes,item_ids, round(length(pos_votes)/2));  
        elseif strcmp(measure, 'top_k')
            pos_matched = is_topk_matched(pred_pos_votes,item_ids,pos_votes,item_ids, measure_size);  
        else
                fprintf('wrong type of measurement');
                exit(0);
        end
    
        n_matched =n_matched+pos_matched;
    end
    if strcmp(measure,'top1')
        fprintf(' out of %d event, average value of top 1 precision: %f\n',n_events,n_matched/n_events);
    elseif strcmp(measure, 'top_half')
        fprintf('out of %d event, average value of top half precisions: %f\n', n_events,n_matched/n_events);
    elseif strcmp(measure,'top_k')
       fprintf('out of %d event, average value of top %d precisions: %f\n', n_events,measure_size,n_matched/n_events);
    end
end