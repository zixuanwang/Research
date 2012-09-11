
files = dir('user_instance/*.dat');
for i = 1:numel(files)
    filename = strcat('user_instance/', files(i).name)
    data = load(filename);
    % split 80% - 20% 
    rows = size(data,1); 
    avg_accuracy = 0;
    for k = 1:10 
        shuffledata = data(randperm(size(data,1)),:);    
        train_rows = round(0.8*rows);
        train_x = shuffledata(1:train_rows,1:42);
        train_y = shuffledata(1:train_rows,43);
        test_x = shuffledata(train_rows+1:end,1:42);
        test_y = shuffledata(train_rows+1:end,43);
        % glmfit only takes 1,0 
        train_y(train_y==-1)=0;
        B = glmfit(train_x, train_y, 'binomial','link','logit');
        % predict
        Z = Logistic(B(1) + test_x * B(2:end));
        Z(Z<=0.5)=-1;
        %how to measure it? accuracy 
        accuracy = nnz(Z==test_y)/size(test_y,1);
        avg_accuracy = avg_accuracy+accuracy; 
    end
    disp(avg_accuracy/10)
end