files = dir('../user_instance/*');
n_users =19;
train_preds = [];
test_preds = [];
train_ys = [];
test_ys = []; 

% for user_instance feature_size = 42   +\theta_0
% for user_instance_withmember feature_size=62
% for user_instance_last_event feature_size=84
parameter_size= 43;
 
for i = 1:numel(files)
    if strcmp(files(i).name,'.') || strcmp(files(i).name,'..')
        continue;
    end
    
    filename = strcat('../user_instance/', files(i).name);
    % filename = strcat('../user_instance_withmember/', files(i).name);

	data_input = load(filename); 
    
    fprintf('####uid: %s\n',files(i).name);
    rows = size(data_input,1);    
    cols = size(data_input,2);
    % randomize data
    data = data_input(randperm(rows),:); 
    train_rows = round(0.8*rows);
	train_x = data(1:train_rows,1:cols-1);
	train_y = data(1:train_rows,cols);
	test_x = data(train_rows+1:rows,1:cols-1);
	test_y = data(train_rows+1:rows,cols);
     %lassglm only take 1 or 0
    train_y(train_y==-1)=0;
    % CV: set cross validation folder(because we need to split train and test randomly, here only take5 cv)
	[B FitInfo] = lassoglm(train_x,train_y,'binomial','NumLambda',25,'CV',5);
    
    % minimum deviance plus one standrad deviation point
	indx = FitInfo.Index1SE;	 
	B0 = B(:,indx);
	% const
	cnst = FitInfo.Intercept(indx);
	% fit weight vector
	B1 = [cnst;B0];
 
	preds = glmval(B1,train_x,'logit');
    train_preds =[train_preds;preds];
    train_ys=[train_ys;train_y];
     
    test_pred = glmval(B1, test_x, 'logit');
    test_y(test_y==-1)=0;
    test_preds =[test_preds;test_pred];
    test_ys=[test_ys;test_y]; 
end


