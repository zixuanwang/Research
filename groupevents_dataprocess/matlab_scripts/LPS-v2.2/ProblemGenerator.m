% From Bin Dai - Generates a big random data set with Bernoulli
% features.
%
% 5/2/10

% dimension of predictor variables (# columns of matrix)
dim = 5000;
% sample size (# rows of matrix)
n = 2000;
% name of output file
outfile = 'data.mat';

% generate matrix elements with half probability 1 and half
% probability 0
X = binornd(1,0.5,n,dim);

% number of patterns in "true" solution
n_patterns=10;
pattern = 1:n_patterns;
% the coefficients corresponding to patterns
coeff = randn(n_patterns,1);

B1 = X(:,pattern);

% the log ratio function
logit = -3 + B1 * coeff;

% responses are generated according to the probabilities from log ratio
p = exp(logit)./(1+exp(logit));
b = binornd(1,p);
b(b==0) = -1;
save(outfile,'X','b');