%
% 9/26/2012 
% IF correclty identified the most voted item. 
% However, more than one items can be voted by equal number
% MAX is not a single value
%

% truev is in ascending order
function pred = is_topk_matched(predv,predv_ids, truev,truev_ids,k)
    true_topkids = get_topk_ids(predv,predv_ids,k);
    pred_topkids = get_topk_ids(truev,truev_ids,k);
    matches = length(intersect(true_topkids,pred_topkids);
    pred = matches/length(true_topkids);
    
end