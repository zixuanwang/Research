data = load('../recommendation_input/eid_iid_fuid_fvote_user5_user5vote.txt');

% get the unique event item pair ..
[val,ia] = unique(data(:,[1,2]));
user5_vote = data(ia,[1,2,end]);
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

n_pos_events = nnz(event_results);

% this user's prediction to p_i
% compute pu 
theta_all = dlmread('output/theta_firstvote.txt');
pu=0.5543*ones(n_events,1);

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

%b = dlmread('output/user5_cvxp_result.dat')
p = 1-exp(b);
q = (prod(((1-p)*ones(1,n_events)).^(A')))';
q(q>=0.5)=1;
nnz(~xor(q,event_results))


%%%% NOT work 10/24
% logistic regression as parameter, solved but not accurate
epsilon=0.1;
cvx_begin
    variables theta(n_features+1) qui(n_events) r(n_events) b(n_users) 
    %tmp = [zeros(n_events,1) - event_results.*(X'*theta+const_b)];
    %minimize (sum(logsumexp(tmp')) +lambda*norm(theta,1))
    %minimize (sum( log(1+ exp(X'*theta)))- sum(event_results.*(log(1+exp(X'*theta))-q) )) 
    minimize( -sum(r(pos_events)) - sum(qui(neg_events)) -sum(Aneg*b) ) 
    subject to 
        r<=0 
        b<=0
        qui<=0
        log(exp(r(pos_events)) + exp(Apos*b+qui(pos_events)))<=0
        % can not perform the operation norm({convex},2)
        % norm(qui + log(1+exp(X'*theta)))<=epsilon
        qui + log(1+exp(X'*theta)) <=epsilon
cvx_end 


pui = 1 - exp(qui); 
pj = 1-exp(b);

pred_pui = prod(1-A + A.*(ones(n_events,1)*(1-pj)'),2); 
%predict accuracy
pred_acc = nnz(xor(event_results,pred_pui))/length(event_results);

