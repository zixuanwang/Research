function [Tlambda, loglike, cnorm] = Functions(beta, lambda)
% calculate l1-regularized log-likelihood function

  global Yvec; global Yp; global Ym;
  global Fvector; global Ap; global Am;
  global sampsize;
  global nbeta;
  
  % evaluate C*z and its exponential; store the latter in the global 
  % variable Fvector as it is useful for gradient and Hessian computations 
  
  beta_nz = find(beta);
  Xbeta = M_mult(beta,beta_nz);
  Ap=find(Xbeta>0); Am=find(Xbeta<=0);

  % evaluate Fvector stably (will be in interval (0,1]).
  Fvector = exp(-abs(Xbeta));
  
  loglike = -sum(Xbeta(Ym));
  loglike = loglike + sum(log(1.0+Fvector(Am)));
  loglike = loglike + sum(Xbeta(Ap)) + sum(log(1.0+Fvector(Ap)));
  loglike = (1/sampsize) * loglike;
  cnorm = sum(abs(beta(1:nbeta-1)));
  Tlambda = loglike + lambda*cnorm;
  
  return;
  