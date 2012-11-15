function [pj,qui,train_q,test_q,train_y,test_y] = influence_mixed_model_per_user(data,place_feature)
    % get the unique event item pair ..
    [val,ia,ic] = unique(data(:,[1,2]),'rows');
    user_vote = data(ia,[1,2,end]);
    n_events = size(user_vote,1);  
    n_users = 19;
    A = zeros(n_events,n_users);
    event_results = user_vote(:,end);
    event_results(event_results==-1)=0;
   
    n_items = 79;
    % item event matrix
    E = zeros(n_events, n_items);
    % ancestor matrix
    for k = 1:n_events
        eid = user_vote(k,1);
        iid = user_vote(k,2);
        this_event = data((data(:,1)==eid)&(data(:,2)==iid),[3,4]);
        uids = this_event(this_event(:,2)==1,1);
        A(k,uids) = 1;
        E(k,iid) = 1;
    end
    
    n_features = size(place_feature,2);
    % compose X matrix for this user 
    X = place_feature;
    % remove all zeros features.
    X(:,all(~any(X),1))=[];

    % pairwise similarity of items in each event.. 
    W = zeros(n_items,n_items);
    for i =1:n_items
        for j= 1:n_items
            W(i,j) = X(i,:)*X(j,:)';
            weight = norm(X(i,:))*norm(X(j,:));
            W(i,j) = W(i,j)/weight;
        end
    end
    n_cv = 3;
    [pj,qui] = cross_validation_influence_mixed_model_per_user(n_cv,n_features,user_vote,A,E,W);
    
    %split into train and test 
    y_idx = randperm(n_events);
    % split 8:2, try 9:1 
    n_train_events = round(0.8*n_events);
    train_idx = y_idx(1:n_train_events);
    test_idx = y_idx(n_train_events+1:end);
    
    % prepare parameter for cvx opt prob
    train_event_results = event_results(train_idx);
    train_A = A(train_idx,:);
    
    %train_q = 1-(1-E(train_idx,:)*qui).* (prod(((1-pj)*ones(1,n_train_events)).^(train_A')))';
    train_q = pui;
    train_y = train_event_results;
    % predict for the test set 
    test_A = A(test_idx,:);
    n_test_events = length(test_idx);
    test_q = 1-(1-E(test_idx,:)*qui).* (prod(((1-pj)*ones(1,n_test_events)).^(test_A')))';
    test_y = event_results(test_idx);
end