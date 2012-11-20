% item_gt: item_id, item_pos_vote, item_neg_vote
function matches = evaluate_existOne(pred_pi, K, items)
 
   item_ids = items(:,2);

   pred6 = [item_ids  pred_pi(item_ids,:)];
   
   % must larger than 3
   %n_voted_items = length(item_ids)
    
   % sort by item score
   sorted_pred6 = sortrows(pred6,-2);
 
   % does the first 3 contains the one which received at least k votes
   sorted_ids =sorted_pred6(:,1);
   top3 = sorted_ids(1:3);
   voted_byK = items(items(:,3)>=K,2);
   exists = intersect(top3,voted_byK);
   matches = length(exists);
 
end