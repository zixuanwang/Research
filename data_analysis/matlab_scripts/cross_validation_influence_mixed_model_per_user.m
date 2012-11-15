
function [pj,this_qui] = cross_validation_influence_mixed_model_per_user(n_cv,n_features,user_vote,A,E,W)
    % get the unique event item pair ..
    n_events = size(user_vote,1);  
    n_users = 19;
    n_items = 79;
    event_results = user_vote(:,end);
    event_results(event_results==-1)=0;
   
    %################ cross validation ########################3
    % split 8:2, 5 times cross validation
    
    y_idx = 1:n_events;
    %n_cv = 5;
    quis = zeros(n_items,n_cv);
    pjs = zeros(n_users,n_cv);
    pui = zeros(n_items,1);
    for d=1:n_cv
        n_test_events = round(n_events*0.2);
     
        test_idx = (d-1)*n_test_events+(1:n_test_events);
        train_idx= setdiff(y_idx,test_idx);
  
        % prepare training and testing 
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
    pjs(:,d) = 1-exp(b);
    quis(:,d) = 1 - exp(qui);
    end
    
    pj = mean(pjs,2);
    this_qui = mean(puis,2);
    %pui = 1-(1-E(train_idx,:)*this_pui).* (prod(((1-pj)*ones(1,n_train_events)).^(train_A')))';
end