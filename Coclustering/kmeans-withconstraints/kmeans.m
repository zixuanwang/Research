function [A,M,E] = kmeans(X,K,iters)
% kmeans clustering
%
% [A,M,E] = kmeans(X,k,iters)
%
% X     - (d x n) d-dimensional input data
% K     -  number of means
%
% returns
% E  - sum of squared distances to nearest mean
% M  - (k x d) matrix of cluster centers
% A  - (n x 1) index of nearest center for each data point
%
% Jakob Verbeek, 2009-2011

N       = size(X,2);
done    = 0;
iter    = 0;
E       = zeros(iters,1);

if numel(K) > 1;     % initialize with given means, compute assignment only
    M = K;
    K = size(M,2);
    iters = 1;
else
    M = X(:,randi(N,K,1));       
end    

SumNormsX = sum(X(:).^2);

while ~done
    iter = iter +1;
    
    NormsM = sum(M.^2,1)/2;
        
    T=bsxfun(@plus, M'*X, -NormsM');        
    [Ei A] = max(T,[],1);
    A=A';
                
    E(iter) =-2*sum(Ei) + SumNormsX;     
    
    if iter < iters;        
                     
        C = accumarray(A,1,[K 1])'; % counts of the centers
        
        M = X*sparse(1:N,A,1,N,K);        
        M = bsxfun(@times,M,C.^-1);
               
        
        C0 = find(C==0);        
        M(:,C0) = X(:,randi(N,numel(C0),1));        
    end

    if iter >= iters; done=1;end  % terminate after given # of iterations
    if iter>1
      if all(Aold==A); done=1;end % terminate when no change in assignments
    end
    Aold = A;
      
    fprintf('Iter %d, error %f\n',iter, E(iter));

end
E = E(1:iter);

