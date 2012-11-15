% JINYUN 9/13/2012
% 10/3/2012 update
% Requires definition of data files with size M*(N+1), where M data points
% with N features, the last column is a vector of M
% binary labels, with values +/-1

%files = dir('../user_instance_withmember/*');
%k = numel(files);
% one column = one weight vector
%files = dir('../user_instance/*');

files = dir('../user_instance_withmember/*');

n_users=19;
train_tprs = zeros(n_users,1);
train_fprs = zeros(n_users,1);
   
test_tprs = zeros(n_users,1);
test_fprs = zeros(n_users,1);

avg_train_acc=0;
avg_test_acc=0;
    
train_accs =zeros(n_users,1);
test_accs = zeros(n_users,1);
uids = zeros(n_users,1);
% for user_instance feature_size = 42   +\theta_0
% for user_instance_withmember feature_size=62
% for user_instance_last_event feature_size=84
parameter_size= 63;
allB = zeros(parameter_size,n_users); 
uid = 1;
threshold=0.5;
for i = 1:numel(files)
    if strcmp(files(i).name,'.') || strcmp(files(i).name,'..')
        continue;
    end
    
    uids(uid) = str2num(files(i).name);
    filename = strcat('../user_instance_withmember/', files(i).name);
    % filename = strcat('../user_instance_withmember/', files(i).name);

	data = load(filename); 
	% 10 folder cross validation, lasso has 2 cv, so here I set 5.
	%[avg_train_acc, avg_test_acc,B_best]= CrossValidation_logits(5,data,'lassoglm');
    %[avg_train_acc, avg_test_acc,B_best]= CrossValidation_logits(10,data,'logit');
    
    [train_tpr,train_fpr,train_acc,test_tpr,test_fpr, test_acc,B1] = measure_lassoglm_pthreshold(data,threshold);
    fprintf('############# user %s \n',files(i).name)
    fprintf(' train_tpr: %.4f, train_fpr:%.4f, train_acc: %.4f\n',train_tpr,train_fpr,train_acc);
    fprintf('test_tpr: %.4f, test_fpr: %.4f, test_acc: %.4f\n',test_tpr,test_fpr,test_acc);
    
    train_tprs(uid) = train_tpr;
    train_fprs(uid) = train_fpr;
    test_tprs(uid) = test_tpr;
    test_fprs(uid) = test_fpr; 
    
    train_accs(uid) = train_acc ;
    test_accs(uid) = test_acc;
    allB(:,uid)=B1;
    uid = uid+1;
end


C = [uids';allB];
D = sortrows(C');
dlmwrite('theta_itemuser.dat',D(:,2:end)');

  
  
