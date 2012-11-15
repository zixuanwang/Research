%
% 10/1/2012 
% whether exists one item which is agreed by half group.
%
function matched = is_half_agreed(predv,predv_ids, truev,truev_ids,half_size)
    half_agreed = truev_ids(truev >= half_size);
    B = [predv predv_ids];
    ranked_B = sortrows(B,1);
   
    % pick top rated half 
    ordered_ids = ranked_B(:,2);
    % choose 1/2 |M_t| 
    n_st = length(ordered_ids);
    n_half = round(n_st/2);
    half_picked = ordered_ids(n_st-n_half+1:end);
 
    % whether exists one item which is agreed by at least k people.
    half_agreed
    half_picked
    match = intersect(half_picked, half_agreed); 
    if isempty(match)
       matched= 0;
    else
        matched = 1;
    end
    
    %fprintf('%d matched out of %d true tops: ratio %f\n',matches,size(true_topkids,1),pre)
end