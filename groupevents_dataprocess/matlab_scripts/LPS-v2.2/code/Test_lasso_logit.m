% calling program for lps.m
%
% JINYUN 9/13/2012

% Requires definition of data files containing X and b, where X is the
% N x k matrix of N data points with k features and b is a vector of N
% binary labels, with values +/-1

% to run on fewer data sets, comment out some of the lines below
% that define entries of "fnames"

files = dir('../../../user_instance_withmember/*.dat');
for i = 1:numel(files)
    filename = strcat('../../../user_instance_withmember/', files(i).name);
    fprintf('\n\n ##### Problem %s\n\n', filename);
	
	data = load(filename); 
	
	% 10 folder cross validation
	[avg_train_acc, avg_test_acc]= CrossValidation_logits(2,data,'lasso_logit');
  	fprintf('%avg_train_acc: avg_test_acc =%6.2f\t%6.2f\n',filename,avg_train_acc, avg_test_acc);
end


  
  
