function [partialGrad] = Gradient(beta, beta_inx)
% computes the entries of the gradients corresponding to indices in
% beta_inx. Assumes that Functions() has been called previously with
% the same beta, to calculate Fvector
  
  global Yvec; global Yp; global Ym;
  global Fvector; global Ap; global Am;
  global sampsize;
  
  YmAm=intersect(Ym,Am);
  YmAp=intersect(Ym,Ap);
  YpAm=intersect(Yp,Am);
  YpAp=intersect(Yp,Ap);
  
  v=zeros(size(Fvector));
  v(YmAm) = -1.0 ./ (1.0+Fvector(YmAm));
  v(YmAp) = -Fvector(YmAp) ./ (Fvector(YmAp)+1.0);
  v(YpAp) = 1.0 ./ (1.0+Fvector(YpAp));
  v(YpAm) = Fvector(YpAm) ./ (Fvector(YpAm) + 1.0);
  
  partialGrad = (1/sampsize) * Mt_mult(v,beta_inx);
  
  return;
  
    