data = load('../recommendation_input/eid_iid_fuid_fvote_user5_user5vote.txt');

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
place_feature = load('../recommend_input/place_bzinfo_feature_matrix.txt');
n_features = 42 ;
X = zeros(n_features, n_events);  % each column is the feature vector for one (e,i) 
for i = 1:n_events
    iid = user5_vote(i,2);
    X(:,i)= place_feature(iid,:)'; 
end
X =[ ones(1,n_events); X];  % add for theata 0 

n_pos_events = nnz(event_results);

% this user's prediction to p_i
pu=0.5543*ones(n_events,1);

pos_events = find(event_results);
neg_events = find(~event_results);
Apos = A(pos_events,:);
Aneg = A(neg_events,:);

% does not work
cvx_begin gp
    variables r(n_pos_events)  b(n_users)   
    %maximize(prod(r(find(event_results)))*prod(A(find(~event_results),:)*b))
    maximize(prod(r).*prod(b'.^(sum(Aneg,1))))
    subject to
        0<=r<=1;
        0<=b<=1;
        %r(find(event_results)) + A(find(event_results),:)*b <=1
        % b*ones(1,n_pos_events) => 19*53 
        % Apos' => 19*53
         r+(1-pu).*(prod((b*ones(1,n_pos_events)).^(Apos')))' <=1;
        %r' + (1-pu)*prod(1-Apos + Apos.*(b*ones(1,n_pos_events))')<=1
cvx_end 


% works 10/22
cvx_begin 
    variables r(n_pos_events) b(n_users)
    minimize(  - sum(r) - sum( Aneg*b ) )
    subject to 
        r<=0
        b<=0
		% .^  matrix dimension must agree
        %log(exp(r)+prod(repmat(exp(b'),[n_pos_events,1]).^Apos))<=0
        %log(exp(r)+prod(1-Apos + Apos.*(exp(b)*ones(1,n_pos_events))'))<=1
        log(exp(r) + (1-pu).*exp(Apos*b)) <=0
cvx_end

%b = dlmread('output/user5_cvxp_result.dat')
p = 1-exp(b);
q = (prod(((1-p)*ones(1,n_events)).^(A')))';
% logistic regression with l1 norm or not?
lambda = 0.25; 
cvx_begin
    variable theta(n_features+1)  
    %tmp = [zeros(n_events,1) - event_results.*(X'*theta+const_b)];
    %minimize (sum(logsumexp(tmp')) +lambda*norm(theta,1))
    minimize (sum( log(1+ exp(X'*theta)))- sum(event_results.*(log(1+exp(X'*theta))-q) )) 
cvx_end 
