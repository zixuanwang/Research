%
% 10/1/2012 
% whether exists one item which is agreed by half group.
%
function matched = is_half_agreed(predv,predv_ids, truev,truev_ids,half_size)
    half_agreed = truev_ids(truev >= half_size);
    B = [predv predv_ids];
    ranked_B = sortrows(B,1);
    
    %pick top rated half 
    ordered_ids = ranked_B(:,2);
    n_voted = length(predv);
    if n_voted <half_size
        fprintf('%d voted, %d half_size\n',n_voted,half_size);
        return
    end
    if n_voted==half_size
        half_picked =  ordered_ids(end);
    end
    if n_voted > half_size
        begin_idx = n_voted-half_size+1;
        half_picked = ordered_ids(begin_idx:end);
    end
    
    % whether exists one item which is agreed by at least k people.
    match = length(intersect(half_picked, half_agreed)); 
    if match>0
       matched= 1;
    else
        matched = 0;
    end
    
    %fprintf('%d matched out of %d true tops: ratio %f\n',matches,size(true_topkids,1),pre)
end