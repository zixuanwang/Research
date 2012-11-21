% compute p_ui for one user all items.
function score = compute_log_fkd(pred, k,d)
    score = 0;
    dp_output = zeros(k,d);
    for u = 1:d
        dp_output(1,u) = prod(log(1-pred(1:u)));
    end
    for j = 2:k
        for u = 1:d
            if u<j 
                dp_output(j,u)=1;
            else
                dp_output(j,u) = log(pred(u)) * dp_output(j-1,u-1) + log(1-pred(u))*dp_output(j-1,u);
            end
        end
    end
    score = dp_output(k,d);
end