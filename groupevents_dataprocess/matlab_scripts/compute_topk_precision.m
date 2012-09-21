%
% 9/20/2012 
% IF correclty identified the most voted item. 
% However, more than one items can be voted by equal number
% MAX is not a single value
%

function pre = compute_topk_precision(v, true_v,k)
    pre = 0;
    
    if k > length(true_v) 
        % if k is bigger than the length of all items, set k = half of
        % the group
        k = round(length(true_v)/2);
    end
    
    % vs: value, vi value's orignal position 
    [vs, vi] = sort(v,'descend');
    
    [tvs, tvi] = sort(true_v,'descend');
    
    % how many items in top k position are relevant: they are indeed top k
    % in the top k true ranking, the position of top k items doesnt matter 
   
    
    pre = length(intersect(vi(1:k),tvi(1:k))); 
    pre = pre/k; 
    
end