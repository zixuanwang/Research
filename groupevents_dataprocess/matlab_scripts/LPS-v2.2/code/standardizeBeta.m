function [beta_standard] = standardizeBeta(beta)
% transform the weight vector calculated for the original X into
% an equivalent weight vector for the standard-form X.
  global Xmat;
  global rows;
  global mu_vec;
  global sigma_vec;
  global sigma_zeros;
  [m n] = size(Xmat); m = length(rows);
  
  % do the standard transformation
  beta_standard(1:n) = sigma_vec.*beta(1:n);
  % ensure that the weights corresponding to zero-information features
  % (those with zero standard deviation) are zero
  beta_standard(sigma_zeros) = 0.0;
  % set the constant term
  beta_standard(n+1) = beta(n+1) + beta(1:n)'*mu_vec;
  
  return;
  

