function [train_acc,test_acc] = measure_lassoglm(data)
    rows = size(data,1);    
    cols = size(data,2);
    train_rows = round(0.8*rows);
	train_x = data(1:train_rows,1:cols-1);
	train_y = data(1:train_rows,cols);
	test_x = data(train_rows+1:rows,1:cols-1);
	test_y = data(train_rows+1:rows,cols);

    %lassglm only take 1 or 0
    train_y(train_y==-1)=0;
    [B fitinfo] = lassoglm(train_x,train_y,'binomial','CV',10);
    b_rows = size(B,1);
    n_lambda = length(fitinfo.Lambda);
    acc = zeros(n_lambda,1);
    for k=1:length(n_lambda)
    	%fprintf(lambda=%6.2e solution has %6d nonzeros. It required %5d iterations and %7.2f seconds\n', ...
        %      lambda_seq(k), numNonzeros(k), iterations(k), times(k));
		a_beta = B(1:b_rows,k); % n*1 
		a_beta_constant = fitinfo.Intercept(k);	
        input_val = train_x*a_beta + a_beta_constant;
		T = Logistic(input_val);
        T(T>=0.5) = 1;
        T(T<0.5) = 0;
		acc(k) = nnz(T==train_y)/train_rows;
    end
    acc
	% get the best lambda for training 
	[train_acc,ind] = max(acc);
    fprintf(' max train acc is : %6.2f, Best Lambda: %6.2e\n',train_acc, fitinfo.Lambda(ind));
	
    input_val = test_x*B(:,ind) + fitinfo.Intercept(ind);
	Z = Logistic(input_val);
	Z(Z>=0.5) = 1;
	Z(Z<0.5) = -1;
	test_acc = nnz(Z==test_y)/size(test_y,1);	
end