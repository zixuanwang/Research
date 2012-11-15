function topkids = get_topk_ids(scores, ids,k)
    B = [scores ids];
    ranked_B = sortrows(B,1);
    % rank prediction by score, in ascending order. 
    ids= ranked_B(:,2);
    scores = ranked_B(:,1);
    unique_scores = unique(scores);
    if length(unique_scores)<= k
        % if k is bigger than the size of voted items, use all items.
        least_val = unique_scores(1);  
    else
        least_val = unique_scores(end-k+1);
    end
    topkids = ids(scores>=least_val);
end