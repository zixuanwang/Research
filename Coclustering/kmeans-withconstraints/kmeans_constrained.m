
% X: n*d, input data points matrix  d dimensional
% con_must: n*n
% con_cannot: n*n
% K : number of clusters

% returns
% E  - sum of squared distances to nearest mean
% M  - (k x d) matrix of cluster centers
% A  - (n x 1) index of nearest center for each data point


function [A, M,  E] = kmeans_constrained(K,X,con_must, con_cannot,iters)
	N       = size(X,1);
	done    = 0;
	iter    = 0;
	E       = zeros(iters,1);
	A = zeros(N,1);
	Aold = zeros(N,1);

	if numel(K) > 1;     % initialize with given means, compute assignment only
    	M = K;
    	K = size(M,1);
    	iters = 1;
	else
   	 	M = X(randi(N,K,1),:);       
	end    

    SumNormsX = sum(X(:).^2);
    while ~done
	    iter = iter +1;

	   	for i = 1:N
	   		% compute the euclidian distance of the point to each center
	   		dist = sum([(M - repmat(X(i,:),K,1)).^2],2);
	   		[val,idx] = min(dist);
	   		is_violated = violate_constraint( i, idx, A, con_must,con_cannot);
	   		if ~is_violated 
	   			A(i)=idx;
	   		end
	   	end

	   	% computer the value of objective function 
	   	% .. what to do with these not yet labeled instance?? 
	   	%for i=1:K
	   	%	index = find(A==i);
	   	%	alldist= sum([(repmat(M(i,:),length(index),1) -  X(index,:)).^2],1);
	   	%	E(iter) = E(iter)+alldist;
	   	%end

	   	% recompute the center of each cluster 	
      	if iter < iters;
	      	for i = 1:K
	         	index = find(A == i);
	         	if ~isempty(index)  
	             	M(i,:) = mean(X(index,:));
	        	 else 
	            	ind=round(rand*N-1);
	            	M(i,:)=X(ind,:);
	        	 end   	 
	        end
	  	end

	    if iter >= iters; done=1;end  % terminate after given # of iterations
	    if iter>1
	      if all(Aold==A); done=1;end % terminate when no change in assignments
	    end
	    Aold = A;
	      
	    fprintf('Iter %d, clustered  %d\n',iter, nnz(A));  
	    %fprintf('Iter %d, error %f\n',iter, E(iter));

	end
	%E = E(1:iter);

end