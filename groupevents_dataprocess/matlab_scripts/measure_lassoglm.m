function [train_acc,test_acc,B1] = measure_lassoglm(data)
    rows = size(data,1);    
    cols = size(data,2);
    train_rows = round(0.8*rows);
	train_x = data(1:train_rows,1:cols-1);
	train_y = data(1:train_rows,cols);
	test_x = data(train_rows+1:rows,1:cols-1);
	test_y = data(train_rows+1:rows,cols);

    %lassglm only take 1 or 0
    train_y(train_y==-1)=0;
    % CV: set cross validation folder(because we need to split train and test randomly, here only take 2 cv)
	[B FitInfo] = lassoglm(train_x,train_y,'binomial','NumLambda',25,'CV',2);
    % minimum deviance plus one standrad deviation point
	indx = FitInfo.Index1SE;
	B0 = B(:,indx);
	% const
	cnst = FitInfo.Intercept(indx);
	% fit weight vector
	B1 = [cnst;B0];

	% measure accuary 
	preds = glmval(B1,train_x,'logit');
	preds(preds>=0.5) = 1;
	preds(preds<0.5) = 0;
	train_acc = nnz(preds==train_y)/size(train_y,1);
	
	% predict on test set 
	test_pred = glmval(B1, test_x, 'logit');
	test_pred(test_pred>=0.5) =1;
	test_pred(test_pred<0.5) = -1;
	test_acc = nnz(test_pred==test_y)/size(test_y,1);
end	
