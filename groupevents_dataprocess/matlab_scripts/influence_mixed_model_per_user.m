function [p,pu,train_q,test_q,train_y,test_y] = influence_mixed_model_per_user(uid,data,place_feature)
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
    
    %split into train and test 
    y_idx = randperm(n_events);
    % split 8:2, try 9:1 
    n_train_events = round(0.8*n_events);
    train_idx = y_idx(1:n_train_events);
    test_idx = y_idx(n_train_events+1:end);

    % compose X matrix for this user 
    X = zeros(n_events, n_features);  % each column is the feature vector for one (e,i) 
    for k = 1:n_events
        iid = user_vote(k,2);
        X(k,:)= place_feature(iid,:); 
    end
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

    % prepare parameter for cvx opt prob
    train_event_results = event_results(train_idx);
    train_A = A(train_idx,:);
    train_pos_events = find(train_event_results);
    train_neg_events = find(~train_event_results);
    Apos = train_A(train_pos_events,:);
    Aneg = train_A(train_neg_events,:);
    n_train_events = length(train_idx);
 
    train_neg_items = zeros(n_items,1);
    train_user_vote = user_vote(train_idx,:);
    for k=1:n_train_events
        iid = train_user_vote(k,2);
        vote =train_user_vote(k,3);
        if vote==-1
        train_neg_items(iid) = train_neg_items(iid) + 1;
        end
    end
    
    lambda = 0.2;
    cvx_begin
        variables theta(n_features+1) qui(n_items) r(n_events) b(n_users) 
        %minimize( -sum(r(pos_events)) - sum(qui.*neg_items) -sum(Aneg*b) + lambda* trace(W*(qui*ones(1,n_items)-repmat(qui',[n_items,1])).^2) )
        minimize( -sum(r(train_pos_events)) - sum(qui.*train_neg_items) -sum(Aneg*b) + lambda* trace(W*(qui*ones(1,n_items)-repmat(qui',[n_items,1])).^2) )
        subject to 
            r <= 0 
            b <= 0
            qui <= 0
            log(exp(r(train_pos_events)) + exp(Apos*b+ E(train_pos_events,:)*qui))<=0
    cvx_end
 

    % pj and the train predict
    p = 1-exp(b);
    pu = 1 - exp(qui); 
    train_q = 1-(1-E(train_idx,:)*pu).* (prod(((1-p)*ones(1,n_train_events)).^(train_A')))';
    train_y = train_event_results;

    % predict for the test set 
    test_A = A(test_idx,:);
    n_test_events = length(test_idx);
    test_q = 1-(1-E(test_idx,:)*pu).* (prod(((1-p)*ones(1,n_test_events)).^(test_A')))';
    test_y = event_results(test_idx);
end