% JINYUN 9/18/2012

% Requires definition of data files with size M*(N+1), where M data points
% with N features, the last column is a vector of M
% binary labels, with values +/-1

%files = dir('../user_instance/*.dat');
%k = numel(files);
% one column = one weight vector
%allB = zeros(43,k); 
%for i = 1:numel(files)
    %filename = strcat('../user_instance/', files(i).name);
    %fprintf('\n\n ##### Problem %s\n\n', filename);
	%data = load(filename); 
	% 10 folder cross validation, lasso has 2 cv, so here I set 5.
	% [avg_train_acc, avg_test_acc,B_best]= CrossValidation_logits(5,data,'lassoglm');
    
  %	fprintf('avg_train_acc: avg_test_acc =%6.2f\t%6.2f\n',avg_train_acc, avg_test_acc);
  %  allB(:,i) = B_best;
    
avg_train_precision = 0;
avg_train_recall = 0;
   
avg_test_precision = 0;
avg_test_recall = 0;
avg_train_acc=0;
avg_test_acc=0;
    
n_users =19;
train_accs =zeros(n_users,1);
test_accs = zeros(n_users,1);
for uid =1:n_users
    filename = strcat('../user_instance/', int2str(uid));
    data = load(filename);
    [train_precision,train_recall,train_acc,test_precision,test_recall, test_acc,B1] = measure_lassoglm_pthreshold(data,threshold);
    fprintf('############# user %i \n',uid)
    fprintf(' train_precision: %.4f, train_recall:%.4f, train_acc: %.4f\n',train_precision,train_recall,train_acc);
    fprintf('test_precision: %.4f, test_recall: %.4f, test_acc: %.4f\n',test_precision,test_recall,test_acc);
    
    avg_train_precision =avg_train_precision + train_precision;
    avg_train_recall =avg_train_recall + train_recall;
    avg_test_precision =avg_test_precision + test_precision;
    avg_test_recall =avg_test_recall + test_recall;
        
    avg_train_acc = avg_train_acc + train_acc;
    avg_test_acc = avg_test_acc + test_acc;
       
    train_accs(uid) = train_acc;
    test_accs(uid) = test_acc;
    
    
end