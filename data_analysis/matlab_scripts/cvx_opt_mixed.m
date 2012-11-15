% 10/29/2012

% use one user and test the optimization problem
data_all = load('../recommendation_input/eid_iid_fuid_fvote_uid_vote_all.txt');
i=3;
data = data_all(data_all(:,5)==i,:);
[val,ia,ic] = unique(data(:,[1,2]),'rows');
 user_vote = data(ia,[1,2,end]);
 n_events = size(user_vote,1);  
 n_users = 19;
 A = zeros(n_events,n_users);
    event_results = user_vote(:,end);
    event_results(event_results==-1)=0;
% ancestor matrix
  for k = 1:n_events
        eid = user_vote(k,1);
        iid = user_vote(k,2);
        this_event = data((data(:,1)==eid)&(data(:,2)==iid),[3,4]);
        uids = this_event(this_event(:,2)==1,1);
        A(k,uids) = 1;
  end

pos_events = find(event_results);
neg_events = find(~event_results);
Apos = A(pos_events,:);
Aneg = A(neg_events,:);

place_feature = load('../recommendation_input/place_bzinfo_feature_matrix.txt');
%Xraw = place_feature; 
%Xraw(:,all(~any(Xraw),1))=[];
n_features = size(place_feature,2);

X = zeros(n_events, n_features);  % each column is the feature vector for one (e,i) 
for k = 1:n_events
    iid = user_vote(k,2);
    X(k,:)= place_feature(iid,:); 
end
% remove all zeros features.
X(:,all(~any(X),1))=[];

% pairwise similarity of items in each event.. 
W = zeros(n_events,n_events);
for i =1:n_events
    for j= 1:n_events
        W(i,j) = X(i,:)*X(j,:)';
        weight = norm(X(i,:))*norm(X(j,:));
        W(i,j) = W(i,j)/weight;
    end
end

lambda = 0.1;
cvx_begin
    variables theta(n_features+1) qui(n_events) r(n_events) b(n_users) 
    %minimize( -sum(r(pos_events)) - sum(qui(neg_events)) -sum(Aneg*b) + lambda* trace(W*abs(qui*ones(1,n_events)-repmat(qui',[n_events,1]))) )
    minimize( -sum(r(pos_events)) - sum(qui(neg_events)) -sum(Aneg*b) + lambda* trace(W*(qui*ones(1,n_events)-repmat(qui',[n_events,1])).^2) )
    subject to 
        r<=0 
        b<=0
        qui<=0
        log(exp(r(pos_events)) + exp(Apos*b+qui(pos_events)))<=0
        % can not perform the operation norm({convex},2)
        % norm(qui + log(1+exp(X'*theta)))<=epsilon
        %qui + log(1+exp(X'*theta)) <=epsilon 
cvx_end

pui = 1 - exp(qui); 
pj = 1-exp(b);

pred_pui = prod(1-A + A.*(ones(n_events,1)*(1-pj)'),2); 
%predict accuracy
pred_acc = nnz(xor(event_results,pred_pui))/length(event_results);