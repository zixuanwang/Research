

a = dlmread('output/full_instance_orderby_event_date_with_existingvote_count.txt');
A = sortrows(a,3);
dlmwrite('output/full_instance_orderby_user_withexistingvote_count.txt',A)
% then use python to serialize 

a = dlmread('output/serialize_fullinstance_byuser_withexistingvote_count.txt');


% ############ LOGIT regression
alluser =load('../user_instance_existingvote/uid_itemfeature_poscnt_negcnt_vote.txt');
n_users = 19;
n_instances = size(alluser,1);
n_features = size(alluser,2)-2; 
train_preds = [];
train_ys=[];
test_preds = [];
test_ys=[];
train_accs = zeros(n_users,1);
train_tprs = zeros(n_users,1);
train_fprs = zeros(n_users,1);
test_tprs = zeros(n_users,1);
test_fprs = zeros(n_users,1);

threshold=0.5;

for i=1:n_users
    data_input = alluser(alluser(:,1)==i,:);
    fprintf('##### uid: %d\n',i);
    data_i = data_input(:,2:end);

    rows = size(data_i,1);    
    cols = size(data_i,2);
    fprintf('### data_i feature row: %d, col: %d',rows,cols);
    % randomize data
    data = data_i(randperm(rows),:); 
    train_rows = round(0.8*rows);
	train_x = data(1:train_rows,1:cols-1);
	train_y = data(1:train_rows,cols);
	test_x = data(train_rows+1:rows,1:cols-1);
	test_y = data(train_rows+1:rows,cols);

    %lassglm only take 1 or 0
    train_y(train_y==-1)=0;
    % CV: set cross validation folder(because we need to split train and test randomly, here only take5 cv)
	[B FitInfo] = lassoglm(train_x,train_y,'binomial','NumLambda',25,'CV',5);
    
    % minimum deviance plus one standrad deviation point
	indx = FitInfo.Index1SE;	 
	B0 = B(:,indx);
	% const
	cnst = FitInfo.Intercept(indx);
	% fit weight vector
	B1 = [cnst;B0];

	preds = glmval(B1,train_x,'logit');
    train_preds =[train_preds;preds];
    train_ys=[train_ys;train_y];
   
    % use 0.5 to predict
    preds(preds>=threshold) = 1;
	preds(preds<threshold) = 0; 
    
    % compute tpr, fpr, accuracy, etc 
    train_tp = nnz(preds & train_y);
    train_tn = nnz(~preds & ~train_y);
    train_fp = nnz(preds & ~train_y);
    train_fn = nnz(~preds & train_y);
    train_tpr = nnz(preds & train_y)/nnz(train_y);
    train_fpr = nnz(preds&~train_y)/nnz(~train_y);
    train_acc = (train_tp+train_tn)/(train_tp+train_tn+train_fp+train_fn);
    train_accs(i) = train_acc;
    train_tprs(i) = train_tpr;
    train_fprs(i) = train_fpr;
    
    test_pred = glmval(B1, test_x, 'logit');
    test_y(test_y==-1)=0;
    test_preds =[test_preds;test_pred];
    test_ys=[test_ys;test_y];
    
    
    test_pred(test_pred>=threshold) = 1;
	test_pred(test_pred<threshold) = 0;
    test_tp = nnz(test_pred & test_y);
    test_tn = nnz(~test_pred & ~test_y);
    test_fp = nnz(test_pred & ~test_y);
    test_fn = nnz(~test_pred & test_y);
    test_tpr = nnz(test_pred & test_y)/nnz(test_y);
    test_fpr = nnz(test_pred & ~test_y)/nnz(~test_y);
    test_tprs(i) = test_tpr;
    test_fpr(i) = test_fpr;
    test_acc = (test_tp+test_tn)/(test_tp+test_tn+test_fp+test_fn);
    test_accs(i) = test_acc;
     
end
