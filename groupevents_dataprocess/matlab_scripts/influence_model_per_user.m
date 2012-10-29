function [p,train_q,test_q,train_y,test_y] = influence_model_per_user(uid,data,place_feature)
    % get the unique event item pair ..

    [val,ia,ic] = unique(data(:,[1,2]),'rows');
    user_vote = data(ia,[1,2,end]);
    n_events = size(user_vote,1);  
    n_users = 19;
    A = zeros(n_events,n_users);
    event_results = user_vote(:,end);
    event_results(event_results==-1)=0;

    % compose the ancestor matrix for each (e,i) 
    for k = 1:n_events
        eid = user_vote(k,1);
        iid = user_vote(k,2);
        this_event = data((data(:,1)==eid)&(data(:,2)==iid),[3,4]);
        uids = this_event(this_event(:,2)==1,1);
        A(k,uids) = 1;
    end

    %split into train and test 
    y_idx = randperm(n_events);
    n_train_events = round(0.8*n_events);
    train_idx = y_idx(1:n_train_events);
    test_idx = y_idx(n_train_events+1:end);

    % compose X matrix for this user 
    n_features = 42 ;
    X = zeros(n_features, n_events);  % each column is the feature vector for one (e,i) 
    for k = 1:n_events
        iid = user_vote(k,2);
        X(:,k)= place_feature(iid,:)'; 
    end
    X =[ ones(1,n_events); X];  % add for theata 0 

    % compute pui: this user's prediction to item i
    theta_all = dlmread('output/theta_firstvote.txt');
    my_theta = theta_all(:,uid);
    pu = Logistic(X'*my_theta);
    

    % prepare parameter for cvx opt prob
    train_event_results = event_results(train_idx);
    train_A = A(train_idx,:);
    train_pos_events = find(train_event_results);
    train_neg_events = find(~train_event_results);
    Apos = train_A(train_pos_events,:);
    Aneg = train_A(train_neg_events,:);
    n_train_events = length(train_idx);
   
    % works 10/22
    cvx_begin 
        variables r(n_train_events) b(n_users)
        minimize(  - sum(r(train_pos_events)) - sum( Aneg*b ) )
        subject to 
            r<=0
            b<=0
            log(exp(r(train_pos_events)) + (1-pu(train_pos_events)).*exp(Apos*b)) <=0
    cvx_end

    % pj and the train predict
    p = 1-exp(b);
    train_q = 1-(1-pu(train_idx)).* (prod(((1-p)*ones(1,n_train_events)).^(train_A')))';
    train_y = train_event_results;

    % predict for the test set 
    test_A = A(test_idx,:);
    n_test_events = length(test_idx);
    test_q = 1-(1-pu(test_idx)).*(prod(((1-p)*ones(1,n_test_events)).^(test_A')))';
    test_y = event_results(test_idx);
end