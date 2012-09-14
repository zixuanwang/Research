function [beta] = unstandardizeBeta(beta_standard)
% transform the weight vector calculated for the standardized X into
% an equivalent weight vector for the original X.
  global Xmat;
  global Yvec;
  global rows;
  global mu_vec;
  global sigma_vec;
  global sigma_zeros;  
  [m n] = size(Xmat); m = length(rows);

  % do the standard transformation
  beta(1:n) = beta_standard(1:n) ./ sigma_vec;
  
  % ensure that the weights corresponding to zero-information features
  % (those with zero standard deviation) are zero
  beta(sigma_zeros) = 0.0;
  % set the constant term. 
  beta(n+1) = beta_standard(n+1) - beta(1:n)*mu_vec;
  
  return;
  

