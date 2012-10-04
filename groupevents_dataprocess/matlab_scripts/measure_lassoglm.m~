%function [train_precision,train_recall,train_acc,test_precision,test_recall, test_acc,B1] = measure_lassoglm(data,threshold)
function [train_tpr,train_fpr,train_acc,test_tpr,test_fpr, test_acc,B1] = measure_lassoglm(data_input,threshold)
    rows = size(data_input,1);    
    cols = size(data_input,2);
    
    % randomize data
    data = data_input(randperm(rows),:);
    
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
	preds(preds>=threshold) = 1;
	preds(preds<threshold) = 0;
    
    train_tp = nnz(preds & train_y);
    train_tn = nnz(~preds & ~train_y);
    train_fp = nnz(preds & train_y);
    train_fn = nnz(~preds & ~train_y);
    %train_precision = train_tp/(train_tp+train_fp);
    train_tpr = nnz(preds & train_y)/nnz(train_y);
    train_fpr = nnz(preds & ~train_y)/nnz(~train_y);
    
    %train_precision = train_tp/nnz(preds==1);
    %train_recall = train_tp/(train_tp+train_fn);
    
    train_acc = (train_tp+train_tn)/(train_tp+train_tn+train_fp+train_fn);
  
	% predict on test set 
	test_pred = glmval(B1, test_x, 'logit');
    
    test_pred(test_pred>=threshold) = 1;
	test_pred(test_pred<threshold) = 0;
    test_y(test_y==-1)=0;
	%test_acc = nnz(test_pred==test_y)/size(test_y,1);
    
    test_tp = nnz(test_pred & test_y);
    test_tn = nnz(~test_pred & ~test_y);
    test_fp = nnz(test_pred & ~test_y);
    test_fn = nnz(~test_pred & test_y);
    test_tpr = nnz(test_pred & test_y)/nnz(test_y);
    test_fpr = nnz(test_pred & ~test_y)/nnz(~test_y);
    
    %test_precision = test_tp/(test_tp+test_fp);
    %test_recall = test_tp/(test_tp+test_fn);
    test_acc = (test_tp+test_tn)/(test_tp+test_tn+test_fp+test_fn);
    
end	
