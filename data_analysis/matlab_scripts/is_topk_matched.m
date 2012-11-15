%
% 9/26/2012 
% top k values. how many ids are matched. 
%
function pre = is_topk_matched(predv,predv_ids, truev,truev_ids,k)
    pred_topkids = get_topk_ids(predv,predv_ids,k);
    true_topkids = get_topk_ids(truev,truev_ids,k);
    matches = length(intersect(true_topkids,pred_topkids));
    pre = matches/size(true_topkids,1);
    %fprintf('%d matched out of %d true tops: ratio %f\n',matches,size(true_topkids,1),pre)
end