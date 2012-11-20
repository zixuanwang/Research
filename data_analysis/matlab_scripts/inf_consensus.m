function pi = inf_consensus(G,learn_qui, learn_pj)
    size_group = length(G);
    %n_items = length(learn_qui);
    
    %pi =zeros(n_items,1);
   
    all_pi = learn_qui*learn_pj + learn_qui*learn_pi'; 
    g_pi = all_pi(:,G);
    pi = sum(g_pi,2)./size_group; 
end