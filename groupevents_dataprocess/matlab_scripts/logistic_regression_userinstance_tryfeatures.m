% input matrix 
% files = dir('user_instance/*.dat');
files = dir('user_instance_withmember/*.dat');
for i = 1:numel(files)
    filename = strcat('user_instance_withmember/', files(i).name);
    data = load(filename);

    rows = size(data,1); 
    cols = size(data,2);
    X = data(:,1:cols-1);
    Y = data(:,cols);
    %%FOR COMPARISON: consider user feature only:
    %n_item_features = 42;
    %X = X(:,n_item_features+1:end);
    %remove feature columns that all values are the same 
    X = X(:,any(diff(X,1)));
    % how many features does the user have now?
    n_features = size(X,2);
 
    fprintf('######Processing user: %d\n',filename);
    %use PCA to reduce dimensions 
    %use fixed dimension 20
    ndim = 20;
    reduced = PCA_reduce(ndim,X);
    data = [reduced, Y];

    %10 folder cross validation
    [avg_train_acc,avg_test_acc]=CrossValidation_LogisticRegression(10,data);

    fprintf('%f\t%f\n',avg_train_acc, avg_test_acc);
end
