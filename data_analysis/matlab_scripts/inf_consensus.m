function pi = inf_consensus(G,learn_qui, learn_pj)
    size_group = length(G);
    %n_items = length(learn_qui);
    
    %make the diagonal to be 1? pj is not normalized???
    [m n] = size(learn_pj);
    learn_pj(1:m+1:end) = 1; 

    % sum_v p(v|u)p(i|v)
    all_pi = learn_qui*learn_pj; 
    g_pi = all_pi(:,G);
    pi = sum(g_pi,2)./(size_group^2); 
end