function [train_acc,test_acc,B1] = measure_logistic_regression(data)
    rows = size(data,1);
    cols = size(data,2);
    train_rows = round(0.8*rows);
    train_x = data(1:train_rows,1:cols-1);
    train_y = data(1:train_rows,cols);
    test_x = data(train_rows+1:rows,1:cols-1);
    test_y = data(train_rows+1:rows,cols);
    % glmfit only takes 1,0 
    train_y(train_y==-1)=0;
    B = glmfit(train_x, train_y, 'binomial','link','logit');
    
    %training error:
    T = Logistic(B(1) + train_x * B(2:end));
    T(T>0.5)=1;
    T(T<=0.5)=0;
    train_acc = nnz(T==train_y)/size(train_y,1);
    
     % predict
    Z = Logistic(B(1) + test_x * B(2:end));
    Z(Z<=0.5)=-1;
    Z(Z>0.5)=1;
    %how to measure it? accuracy 
    test_acc = nnz(Z==test_y)/size(test_y,1);
end
