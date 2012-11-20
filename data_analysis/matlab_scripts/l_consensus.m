function pi = l_consensus(M)
    size_group = size(M,2);
    n_items = size(M,1);
    pi = zeros(n_items,1);
    for i=1:n_items
        pi(i)=compute_fkd(M(i,:), ceil(2/size_group), size_group);
    end
end