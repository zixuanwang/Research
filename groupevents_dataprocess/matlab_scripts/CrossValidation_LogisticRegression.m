function [avg_train_acc,avg_test_acc] = CrossValidation_LogisticRegression(n_folder, data)
    avg_train_acc=0;
    avg_test_acc = 0;
    rows = size(data,1);
    for k = 1:n_folder 
        shuffledata = data(randperm(rows),:);    
        % split 80% - 20%
        [train_acc,test_acc] = measure_logistic_regression(shuffledata);
        avg_test_acc = avg_test_acc+ test_acc;
        avg_train_acc = avg_train_acc + train_acc;
    end
    avg_train_acc = avg_train_acc/10;
    avg_test_acc = avg_test_acc/10;
end