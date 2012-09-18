% JINYUN 9/18/2012

% Requires definition of data files with size M*(N+1), where M data points
% with N features, the last column is a vector of M
% binary labels, with values +/-1

files = dir('../user_instance/*.dat');
k = numel(files);
% one column = one weight vector
allB = zeros(43,k); 
for i = 1:numel(files)
    filename = strcat('../user_instance/', files(i).name);
    fprintf('\n\n ##### Problem %s\n\n', filename);
	data = load(filename); 
	% 10 folder cross validation, lasso has 2 cv, so here I set 5.
	 [avg_train_acc, avg_test_acc,B_best]= CrossValidation_logits(5,data,'lassoglm');
    
  	fprintf('avg_train_acc: avg_test_acc =%6.2f\t%6.2f\n',avg_train_acc, avg_test_acc);
    allB(:,i) = B_best; 
    
end