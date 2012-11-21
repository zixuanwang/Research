function rgi = evaluateRealPosVote(pred_pi, items,size_group)
    item_ids = items(:,2);
    voted_users = items(:,end);
    n_voted_users= max(voted_users);
    pred6 = [item_ids  pred_pi(item_ids,:)];
   
    % must larger than 3
    %n_voted_items = length(item_ids)
    
    % sort by item score
    sorted_pred6 = sortrows(pred6,-2);
 
    % does the first 3 contains the one which received at least k votes
    sorted_ids =sorted_pred6(:,1);
    top3 = sorted_ids(1:3);
    rgi = 0;
    for i =1:3
        iid = top3(i);
        rgi = rgi+items(items(:,2)==iid,3);
    end
    %rgi = rgi/n_voted_users;
    rgi = rgi/size_group;
end