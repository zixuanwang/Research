function [train_acc,test_acc] = measure_lasso_logistic_regression(data)
    rows = size(data,1);    
    cols = size(data,2);
    train_rows = round(0.8*rows);
	train_x = data(1:train_rows,1:cols-1);
	train_y = data(1:train_rows,cols);
	test_x = data(train_rows+1:rows,1:cols-1);
	test_y = data(train_rows+1:rows,cols);
		
	lambda_fac = 0.1;
    %fprintf(' calling lps with target lambda=%5.2f * lambda_max\n', ...
    %        lambda_fac);
    
    % use Hessian sampling with sample fraction given here. (1=evaluate
   	% the exact reduced Hessian as required.)
   	hessianSampleFrac = 1.0;
    
    [beta, lambda_seq, loglike, Tlambda, numNonzeros, iterations, err, times] = ...
        lps(lambda_fac, ...
            train_x, ...
            train_y, ...
            'Initialization', 0, ...
            'Verbosity', 0, ...
            'Standardize', 1, ...
            'Continuation', 1, ...
            'initialLambda', 1.0, ...
            'continuationSteps', 10, ...
            'Newton', 1, ...
            'HessianSampleFraction', hessianSampleFrac, ...
            'FullGradient', 0, ...  
            'GradientFraction', 0.1, ...          
            'InitialAlpha', 1.0, ...
            'MaxIter', 500, ...
            'StopTol', 1.e-6, ...
            'IntermediateTol', 1.e-6);
    
    fprintf('\n');
    fprintf(1,' Data set has %d vectors with %d features\n\n', size(train_x,1), ...
            size(train_x,2));
    
    if err==1
     		 fprintf(' ****** ERROR: AlphaMax exceeded\n\n');
    elseif err==2
      		fprintf(' ****** ERROR: MaxIter exceeded\n\n');
    end
    
	b_rows  = size(beta,1); % n+1 feature weight 
    
	acc= zeros(length(times),1);
    for k=1:length(times)
    	%fprintf(1,'lambda=%6.2e solution has %6d nonzeros. It required %5d iterations and %7.2f seconds\n', ...
        %      lambda_seq(k), numNonzeros(k), iterations(k), times(k));
		a_beta = beta(1:b_rows-1,k); % n*1 
		a_beta_constant = beta(b_rows,k);	
        input_val = train_x*a_beta + a_beta_constant;
		T = Logistic(input_val);
        T(T>=0.5) = 1;
        T(T<0.5) = -1;
		acc(k) = nnz(T==train_y)/train_rows;
	end
	% get the best lambda for training 
	[train_acc,ind] = max(acc);
    fprintf(' max train acc is : %6.2f, Best Lambda: %6.2e\n',train_acc, lambda_seq(ind));
	
    input_val = test_x*beta(1:(b_rows-1),ind)+beta(b_rows,ind);
	Z = Logistic(input_val);
	Z(Z>=0.5) = 1;
	Z(Z<0.5) = -1;
	test_acc = nnz(Z==test_y)/size(test_y,1);	
    	
	fprintf(' Total time: %6.2e\n', sum(times));
end