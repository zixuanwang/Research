% 10/2/2012
% consider the past event. with final choice

function [avg_train_acc,avg_test_acc] = logistic_regression_past_event( )
    threshold = 0.5;
    n_users =19;
    train_tprs = zeros(n_users,1);
    train_fprs = zeros(n_users,1);
   
    test_tprs = zeros(n_users,1);
    test_fprs = zeros(n_users,1);

    avg_train_acc=0;
    avg_test_acc=0;
    feature_size = 85;
    allB = zeros(feature_size,n_users);
    train_accs =zeros(n_users,1);
    test_accs = zeros(n_users,1);
    for uid =1:n_users

        filename = strcat('../user_instance_pastevent/', int2str(uid));
        data = load(filename);
    
        %[train_precision,train_recall,train_acc,test_precision,test_recall, test_acc,B1] = measure_lassoglm_pthreshold(data,threshold);
        [train_tpr,train_fpr,train_acc,test_tpr,test_fpr, test_acc,B1] = measure_lassoglm_pthreshold(data,threshold);
        fprintf('############# user %i \n',uid)
        fprintf(' train_tpr: %.4f, train_fpr:%.4f, train_acc: %.4f\n',train_tpr,train_fpr,train_acc);
        fprintf('test_tpr: %.4f, test_fpr: %.4f, test_acc: %.4f\n',test_tpr,test_fpr,test_acc);

        train_tprs(uid) = train_tpr;
        train_fprs(uid) = train_fpr;
        test_tprs(uid) = test_tpr;
        test_fprs(uid) = test_fpr; 
        
        avg_train_acc = avg_train_acc + train_acc;
        avg_test_acc = avg_test_acc + test_acc;
       
        train_accs(uid) = train_acc;
        test_accs(uid) = test_acc;
        allB(:,uid) = B1;
    end
   fprintf('avg_train_acc: %.4f, avg_test_acc: %.4f\n',avg_train_acc/n_users,avg_test_acc/n_users);
    
end