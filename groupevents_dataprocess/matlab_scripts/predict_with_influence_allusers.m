 
data = load('../recommendation_input/eid_iid_fuid_fvote_uid_vote_all.txt');
place_feature = load('../recommendation_input/place_bzinfo_feature_matrix.txt');
n_users=19;
train_preds = [];
train_ys=[];
test_preds = [];
test_ys=[];
train_accs = zeros(n_users,1);
train_tprs = zeros(n_users,1);
train_fprs = zeros(n_users,1);
test_tprs = zeros(n_users,1);
test_fprs = zeros(n_users,1);
test_accs = zeros(n_users,1);
learn_pj = zeros(n_users,n_users);
for i = 1:19
    data_i = data(data(:,5)==i,:);
    [pj, train_q,test_q, train_y, test_y] = influence_model_per_user(i,data_i,place_feature);
	learn_pj(:,i) = pj; % each column is a pj for user i
	test_preds =[test_preds;test_q];
	train_preds = [train_preds;train_q];
	train_ys = [train_ys;train_y];
	test_ys = [test_ys;test_y];
	% measure accuracy
	% use 0.5 to predict

    threshold=0.5;
    preds = train_q;
    preds(preds>=threshold) = 1;
    preds(preds<threshold) = 0; 
    
    % compute tpr, fpr, accuracy for training set
    train_tpr = nnz(preds & train_y)/nnz(train_y);
    train_fpr = nnz(preds&~train_y)/nnz(~train_y);
    train_acc = (nnz(~xor(preds,train_y)))/length(train_y);
    train_accs(i) = train_acc;
    train_tprs(i) = train_tpr;
    train_fprs(i) = train_fpr;

	test_pred = test_q;
    test_pred(test_pred>=threshold) = 1;
    test_pred(test_pred<threshold) = 0; 
    test_tpr = nnz(test_pred & test_y)/nnz(test_y);
    test_fpr = nnz(test_pred &~test_y)/nnz(~test_y);
    test_acc = (nnz(~xor(test_pred, test_y)))/length(test_y);
    test_accs(i) = test_acc;
    test_tprs(i) = test_tpr;
    test_fprs(i) = test_fpr;
end 


% fetch column of pj for user i
dlmwrite('output/cvx_influence_pj_alluser.dat', learn_pj, 'delimiter', '\t');
% training prediction results
a = [train_preds,train_ys];
aa=sortrows(a,1);
dlmwrite('output/withinfluence_firstvote_train_predtrue.dat', a, 'delimiter', '\t');
dlmwrite('output/withinfluence_firstvote_train_predtrue_sorted.dat', aa, 'delimiter', '\t');

% test prediction results
b = [test_preds,test_ys];
bb=sortrows(b,1);
dlmwrite('output/withinfluence_firstvote_test_predtrue.dat', b, 'delimiter', '\t');
dlmwrite('output/withinfluence_firstvote_test_predtrue_sorted.dat',bb, 'delimiter', '\t');

% accuracy across users
dlmwrite('output/withinfluence_firstvote_train_tpr_fpr_accs.dat',[train_tprs, train_fprs, train_accs],'delimiter', '\t');
dlmwrite('output/withinfluence_firstvote_test_tpr_fpr_accs.dat',[test_tprs, test_fprs, test_accs],'delimiter', '\t');

