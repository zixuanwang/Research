function [Av] = M_mult(v,inx)
  
  global Xmat;
  global rows;
  global mu_vec;
  global sigma_vec;
  global sampsize;
  global nbeta;
  global standardized;
  
  inxr = setdiff(inx,[nbeta]);
  Av = zeros(sampsize,1);

  if ~isempty(inxr)
    if standardized
      v_sig = v(inxr) ./ sigma_vec(inxr);
      temp  = mu_vec(inxr)'*v_sig;
      Av = Xmat(rows,inxr) * v_sig - temp;
    else % not standardized 
      Av = Xmat(rows,inxr)*v(inxr);
    end
  end
    
  if ismember([nbeta],inx)
    Av = Av + v(nbeta);
  end
  
  return;
  