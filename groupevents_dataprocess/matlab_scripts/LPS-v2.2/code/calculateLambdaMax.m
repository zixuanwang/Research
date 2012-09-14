function [lambda_max,intercept] = calculateLambdaMax()
% calculate lambda_max as defined in "An Interior-Point Method for
% Large-Scale l1-Regularized Logistic Regression" by Koh, Kim, Boyd,
% JMLR 8 (2007), pp. 1519-1555.
  
  global Xmat;
  global Yvec;
  global rows;
  global mu_vec;
  global sigma_vec;
  
  [m n] = size(Xmat); m = length(rows);
  
  m_plus = size(find(Yvec(rows)==1),1);
  m_minus = size(find(Yvec(rows)==-1),1);
  fprintf(1,' calculateLambdaMax: n=%d, m=%d, m+=%d, m-=%d\n', ...
          n, m, m_plus, m_minus);
  
  Ytilde=zeros(m,1);
  Ytilde(find(Yvec(rows)==1))  = m_minus/m;
  Ytilde(find(Yvec(rows)==-1)) = -m_plus/m;
  
  inx=[1:n];
  Xty = Mt_mult(Ytilde,inx);
  lambda_max = norm(Xty,inf);
  lambda_max = lambda_max/m;
  
  % calculate optimal value of the intercept term
  intercept = log(m_minus/m_plus);
  
  return;
