function [Atv] = Mt_mult(v,inx)

  global Xmat;
  global rows;
  global mu_vec;
  global sigma_vec;
  global sampsize;
  global nbeta;
  global standardized;

  % remove the final component, if neccessary (include it explicitly later)
  inxr = setdiff(inx,[nbeta]);
  Atv=[];
  
  temp = sum(v);

  if ~isempty(inxr)
    if standardized
      Atv = Xmat(rows,inxr)'*v - mu_vec(inxr)*temp;
      Atv = Atv ./ sigma_vec(inxr);
    else
      Atv = Xmat(rows,inxr)'*v;
    end
  end
  
  if ismember([nbeta],inx)
    Atv = [Atv; temp];
  end
  
  return;
  