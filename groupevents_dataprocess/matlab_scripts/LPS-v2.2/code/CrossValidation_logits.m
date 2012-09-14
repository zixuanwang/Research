function [avg_train_acc,avg_test_acc] = CrossValidation_logits(n_folder, data, method_name)
    avg_train_acc=0;
    avg_test_acc = 0;
    rows = size(data,1);
    for k = 1:n_folder 
        shuffledata = data(randperm(rows),:);    
        % split 80% - 20%
        if strcmp(method_name,'logit')
            [train_acc,test_acc] = measure_logistic_regression(shuffledata);
        elseif strcmp(method_name,'lasso_logit')
            [train_acc,test_acc] = measure_lasso_logistic_regression(shuffledata);
        else
            fprintf('got %s, wrong method type! \n',method_name);
        end
        avg_test_acc = avg_test_acc+ test_acc;
        avg_train_acc = avg_train_acc + train_acc;
    end
    avg_train_acc = avg_train_acc/n_folder;
    avg_test_acc = avg_test_acc/n_folder;
end