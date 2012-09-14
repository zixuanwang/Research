% input matrix 
% files = dir('user_instance/*.dat');
files = dir('../user_instance_withmember/*.dat');
for i = 1:numel(files)
    filename = strcat('../user_instance_withmember/', files(i).name)
    data = load(filename);
     
    rows = size(data,1); 
    cols = size(data,2);
    X = data(:,1:cols-1);
    Y = data(:,cols);
    
    %remove feature columns that all values are the same 
    X=X(:,any(diff(X,1)));
    % how many features does the user have now?
    n_features = size(X,2);
    
    % how many instances does the user have?
    data = [X, Y];
    cols = size(data,2);
    
    fprintf('Number of instances: %d, number of features: %d\n',size(X,1),n_features);
  
    avg_train_acc=0;
    avg_accuracy = 0;
    % 10 folder cross validation
    for k = 1:10 
        shuffledata = data(randperm(rows),:);    
        % split 80% - 20%
        train_rows = round(0.8*rows);
        train_x = shuffledata(1:train_rows,1:cols-1);
        train_y = shuffledata(1:train_rows,cols);
        test_x = shuffledata(train_rows+1:end,1:cols-1);
        test_y = shuffledata(train_rows+1:end,cols);
        % glmfit only takes 1,0 
        train_y(train_y==-1)=0;
        B = glmfit(train_x, train_y, 'binomial','link','logit');
    
        %training error:
        T = Logistic(B(1) + train_x * B(2:end));
        T(T>0.5)=1;
        T(T<=0.5)=0;
        train_acc = nnz(T==train_y)/length(train_y);
        avg_train_acc = avg_train_acc+train_acc;
    
        % predict
        Z = Logistic(B(1) + test_x * B(2:end));
        Z(Z<=0.5)=-1;
        Z(Z>0.5)=1;
        %how to measure it? accuracy 
        accuracy = nnz(Z==test_y)/length(test_y);
        avg_accuracy = avg_accuracy+accuracy; 
    end

    fprintf('%f\t%f\n',avg_train_acc/10, avg_accuracy/10);
end