data = load('../recommendation_input/eid_iid_fuid_fvote_user5_user5vote.txt');

% get the unique event item pair ..
user5_vote = data(unique(data(:,[1,2])),[1,2,end]);
n_events = size(user5_vote,1);
n_users = 19;
A = zeros(n_events,n_users);
event_results = user5_vote(:,end);
event_results(event_results==-1)=0;
 
for i = 1:n_events
    eid = user5_vote(i,1);
    iid = user5_vote(i,2);
    this_event = data((data(:,1)==eid)&(data(:,2)==iid),[3,4]);
    uids = this_event(this_event(:,2)==1,1);
    A(i,uids) = 1;
end

cvx_begin gp
    variables r(n_events)  b(n_users)   
    maximize(prod(r(find(event_results)))*prod(find(A(find(~event_results),:)*b)))
    subject to
        0<=r<=1
        0<=b<=1
        r + A(find(event_results),:)*b <=1
cvx_end 