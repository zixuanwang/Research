%
% 9/17/2012 
% IF correclty identified the most voted item. 
% However, more than one items can be voted by equal number
% MAX is not a single value
%

function matched = is_maximum_matched(v, true_v)
    matched = 0;
    
    [vs, vi] = sort(v,'descend');
    
    [tvs, tvi] = sort(true_v,'descend');
    
    % get the maximum value
    max_val = vs(1);
    % get indexs of maximum values if more than one maximum
    max_idxs = vi(vs==max_val);
    
    % get the maximum value 
    max_t_val = tvs(1);
    max_tidxs = tvi(tvs==max_t_val);
    
    if nnz(ismember(max_idxs, max_tidxs))>0
        matched =1;
    end

end