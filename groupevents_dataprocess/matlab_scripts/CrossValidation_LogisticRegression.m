function [avg_train_acc,avg_test_acc] = CrossValidation_LogisticRegression(n_folder, data)
    avg_train_acc=0;
    avg_test_acc = 0;
    rows = size(data,1);
    cols = size(data,2);
    % 10 folder cross validation
    fprintf('== Processing with number of instance and features: %d\t%d\n',rows,cols-1);
    for k = 1:n_folder 
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
        train_acc = nnz(T==train_y)/size(train_y,1);
        avg_train_acc = avg_train_acc+train_acc;
    
        % predict
        Z = Logistic(B(1) + test_x * B(2:end));
        Z(Z<=0.5)=-1;
        Z(Z>0.5)=1;
        %how to measure it? accuracy 
        accuracy = nnz(Z==test_y)/length(test_y);
        avg_test_acc = avg_test_acc+accuracy; 
    end
    avg_train_acc = avg_train_acc/10;
    avg_test_acc = avg_test_acc/10;
    
    end