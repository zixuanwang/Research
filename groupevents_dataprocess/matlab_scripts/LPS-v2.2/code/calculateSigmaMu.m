function [sigma_vec, sigma_zeros, mu_vec] = calculateSigmaMu(X,rows)
  % calculate std devation and mean vectors for the columns of X.
  [m n] = size(X); m = length(rows);
  mu_vec = X(rows,:)'*ones(m,1) / m;
  sigma_vec = (X(rows,:).^2)'*ones(m,1);
  sigma_vec = (sigma_vec/m) - mu_vec.^2;
  sigma_vec = sqrt(sigma_vec);
  
  % locate the zero sigmas - these indicate the columns of X that have
  % constant entries. Record these - their correpsonding weights must
  % be zeroed in the postprocessing step - and reset them to a
  % constant value, to essentially eliminate these columns from
  % further consideration. (Their standardized form will be zero.)
  sigma_zeros = find(sigma_vec==0);
  sigma_vec(sigma_zeros) = min(mean(sigma_vec),1);
  
  return;
  
  