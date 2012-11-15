%
% 9/26/2012 
% how many top half matched

function pre = is_top_half_matched(predv,predv_ids, truev,truev_ids)
    B = [predv  predv_ids];
    ranked_B = sortrows(B,1); 
    ids= ranked_B(:,2);
    votes = ranked_B(:,1);
    
    pre = 0;
    k = round(length(truev)/2);
    pre = length(intersect(ids(end-k+1:end),truev_ids(end-k+1:end))); 
    pre = pre/k; 
end