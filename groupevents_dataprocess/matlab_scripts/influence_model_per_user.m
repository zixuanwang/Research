function q = influence_model_per_user(uid,data)
    % get the unique event item pair ..
    user5_vote = data(unique(data(:,[1,2])),[1,2,end]);
    n_events = size(user5_vote,1);  
    n_users = 19;
    A = zeros(n_events,n_users);
    event_results = user5_vote(:,end);
    event_results(event_results==-1)=0;
 
    % compose the ancestor matrix for each (e,i) 
    for i = 1:n_events
        eid = user5_vote(i,1);
        iid = user5_vote(i,2);
        this_event = data((data(:,1)==eid)&(data(:,2)==iid),[3,4]);
        uids = this_event(this_event(:,2)==1,1);
        A(i,uids) = 1;
    end

    % compose X matrix for this user 
    place_feature = load('../recommendation_input/place_bzinfo_feature_matrix.txt');
    n_features = 42 ;
    X = zeros(n_features, n_events);  % each column is the feature vector for one (e,i) 
    for i = 1:n_events
        iid = user5_vote(i,2);
        X(:,i)= place_feature(iid,:)'; 
    end
    X =[ ones(1,n_events); X];  % add for theata 0 

    % this user's prediction to p_i
    % compute pu 
    theta_all = dlmread('output/theta_firstvote.txt');
    my_theta = theta_all(:,uid);
    pu = X'*my_theta;
    %pu=0.5543*ones(n_events,1);

    pos_events = find(event_results);
    neg_events = find(~event_results);
    Apos = A(pos_events,:);
    Aneg = A(neg_events,:);

    % works 10/22
    cvx_begin 
        variables r(n_events) b(n_users)
        minimize(  - sum(r(pos_events)) - sum( Aneg*b ) )
        subject to 
            r<=0
            b<=0
        	% .^  matrix dimension must agree
            %log(exp(r)+prod(repmat(exp(b'),[n_pos_events,1]).^Apos))<=0
            %log(exp(r)+prod(1-Apos + Apos.*(exp(b)*ones(1,n_pos_events))'))<=1
            log(exp(r(pos_events)) + (1-pu(pos_events)).*exp(Apos*b)) <=0
    cvx_end

    p = 1-exp(b);
    dlmwrite(strcat('output/cvx_pj_user',str(uid)),p);
    q = (prod(((1-p)*ones(1,n_events)).^(A')))';
  
end