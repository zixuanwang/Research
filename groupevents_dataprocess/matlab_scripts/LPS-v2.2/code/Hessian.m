function [partialHessian] = Hessian(beta, beta_inx)
% evaluates the (square) reduced Hessian corresponding to the indices in
% beta_inx. Assumes that Functions() has been called previously to
% calculate Fvector. 
  global Xmat;
  global Yvec; global Yp; global Ym;
  global rows;
  global hessianFraction;
  global mu_vec;
  global sigma_vec;
  global Fvector; 
  global sampsize;
  global nbeta;
  global standardized;
  
  sizeHess=size(beta_inx,1);
  partialHessian = [];
  
 % fprintf(' in Hessian with fraction=%5.2f\n', hessianFraction);
  
  % if hessianFraction < 1, sample a subset of the data (fresh
  % sample each time).
  if hessianFraction >= 1
    hessianCount = sampsize;
    hessianSample = 1:sampsize;
  else
    % at least 10 sample elements
    hessianCount = max(round(hessianFraction*sampsize),10);
    hessianCount = min(hessianCount,sampsize);
    hessianSample = randperm(sampsize);
    hessianSample = hessianSample([1:hessianCount]);
  end
  hessianSampleRows = rows(hessianSample);
  
  % useful transformation of Fvector
  Ftemp = Fvector(hessianSample)./((1+Fvector(hessianSample)).^2);
%  Ftemp
  
  % reduced index set
  inxr = setdiff(beta_inx,[nbeta]);

  % deal with the special case in which beta_inx contains only the
  % intercept term
  if isempty(inxr)
    etd = sum(Ftemp);
    partialHessian = etd / hessianCount;
    return;
  end
  
  % always need these quantities
  Xtd = Xmat(hessianSampleRows,inxr)'*Ftemp;
  etd = sum(Ftemp);
  
  if standardized
    partialHessian = ...
        Xmat(hessianSampleRows,inxr)'*((Ftemp*ones(1,length(inxr))).*Xmat(hessianSampleRows,inxr));
    partialHessian = partialHessian ...
        - Xtd*mu_vec(inxr)' - mu_vec(inxr)*Xtd' + ...
        etd*mu_vec(inxr)*mu_vec(inxr)';
    partialHessian = ...
        diag(1./sigma_vec(inxr))*partialHessian*diag(1./sigma_vec(inxr));
    if ismember([nbeta],beta_inx)
      vtemp = (Xtd - mu_vec(inxr)*etd) ./ sigma_vec(inxr);
      partialHessian = [partialHessian vtemp; vtemp' etd];
    end
  else % not standardized
    partialHessian = ...
        Xmat(hessianSampleRows,inxr)'*((Ftemp*ones(1,length(inxr))).*Xmat(hessianSampleRows,inxr));
    if ismember([nbeta],beta_inx)
      partialHessian = [partialHessian Xtd; Xtd' etd];
    end
  end
  
  % symmetrize and scale 
  partialHessian = partialHessian + partialHessian';
  partialHessian = (0.5/hessianCount) * partialHessian;
  
  return;
  