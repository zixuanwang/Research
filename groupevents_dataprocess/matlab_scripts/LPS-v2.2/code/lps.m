function [beta, lambda_seq, loglike, Tlambda, numNonzeros, ...
          iterations, err, times, nfunc, ngrad] = ...
    lps(lambda_fac, X, b, varargin)
  %
  % Minimize the l1-regularized log reg function. Use continuation strategy
  % if requested. 
  %
  % SJW 2/10/11
  % 
  % ================
  % mandatory inputs:
  % 
  % lambda_fac: the target value of the regularization parameter,
  %             expressed as a fraction of lambda_max
  %
  % X:          design matrix
  % b:          vector of labels +1 or -1.
  % 
  % =======
  % outputs:
  %
  % beta:         final values of parameter vectors. If user requests beta
  %               only for lambda_fac, this is a single vector. Otherwise,
  %               it contains one column for each lambda visited by the
  %               continuation algorithm. (see optional input FinalOnly.)
  %
  % lambda_seq:   vector of lambda values visited by the continuation scheme.
  %
  % loglike:      logistic regression function at final beta. Again, this is
  %               either a single value for the target lambda_fac, or a
  %               vector with one entry for each lambda visited.
  %
  % Tlambda:      regularized logistic regression function at final
  %               beta. Same structure as for previous output arguments.
  %
  % numNonzeros:  number of nonzeros in the final beta. Same structure as
  %               for previous output arguments.
  %
  % iterations:   iterations required. Same structure as for previous
  %               arguments.
  %
  % err: returns 0 if successful termination for all lambda; 1 if
  %               alpha exceeds AlphaMax; 2 if MaxIter exceeded.
  %
  % times:        runtimes for each lambda value visited OR a single total
  %               runtime, at user's option.
  % 
  % nfunc:        number of function evaluations for each lambda
  %               value, or just for final value, depending on FINALONLY
  % 
  % ngrad:        number of equivalent full gradient evaluations
  %               for each lambda, or just for final value,
  %               depending on FINALONLY
  %               
  % 
  % ===============
  % optional inputs:
  %
  % 'Sample' must be either a number in the range [0,1] or an array
  %          of distinct integers drawn from the set {1,2,...,nX},
  %          where nX is the number of rows in Xmat (i.e. number of
  %          data points)
  %            0 or 1 -> no sampling - use the whole data set
  %            in (0,1) -> sample this fraction of the data set
  %            array -> use these rows from Xmat to define a
  %                     sampled approximate problem
  %
  % 'Initialization' must be one of {0,array}
  %            0 -> Initialize at beta=0
  %        array -> use this argument as the initial beta. Note that the
  %                 use or non-use of standardization should be taken into
  %                 account in setting beta.
  %            Default = 0.
  %
  % 'Verbosity' = output level
  %            0 -> little output
  %            1 -> more output
  %            2 -> still more output
  %            Default = 0.
  %
  % 'Standardize' = standardize Xmat. This flag must be set to 1, and the 
  %                 implicit inputs listed below must be present, if
  %                 standardization is to be used.
  %            0 -> don't standardize (default)
  %            1 -> standardize
  %
  % 'Continuation' = use continuation strategy to start with a larger value
  %                  of lambda, decreasing it successively to lambda_fac.
  %            0 -> don't use continuation (default)
  %            1 -> use continuation
  %
  % 'initialLambda' = first value of lambda to be used in the continuation
  %                   scheme,  expressed as a fraction of lambda_max
  %                Default = 1.0
  %
  % 'continuationSteps' = number of lambda values to use in continuation
  %                       PRIOR to target value lambda_fac. Ignored if
  %                       continuation is not used.
  %                Default = 10
  %
  % 'accurateIntermediates' = indicates whether accurate solutions are
  %                           required for lambda values other than
  %                           the target value lambda_fac. If not set,
  %                           the looser tolerance defined in
  %                           "IntermediateTol" is used. Ignored if
  %                           continuation is not used.
  %                0 -> don't need accurate intemediates (default)
  %                1 -> calculate accurate intermediates.
  %
  % 'PrintFreq' = print frequency
  %            print a progress report every NI iterations, where NI
  %            is the supplied value of this parameter (integer >= 1)
  %
  % 'Newton' = use projected Newton steps?
  %            0 -> no Newton steps (default)
  %            1 -> try projected Newton steps
  %
  % 'NewtonThreshold' = maximum size of free variable subvector for Newton
  %            Default = 500.
  %
  % 'HessianSampleFraction' = sample fraction of terms to use in
  %                           approximate Hessian calculation. In (0.01,1].
  %            Default = 1.0
  %
  % 'BB' = use Barzilai-Borwein steplength for first-order step?
  %            0 -> don't use BB steps (default)
  %            1 -> standard BB formula
  %            (NOT CURRENTLY USED)
  %
  % 'Monotone' = force decrease in first-order step?
  %            0 -> don't force monotonicity (allowed only if BB=1)
  %            1 -> force monotonicity (default)
  %            (NOT CURRENTLY USED)
  %
  % 'FullGradient' = strategy for selecting partial gradientvector
  %           0 -> use randomly selected partial gradient,
  %                including current active components ("biased")
  %           1 -> use full gradient vector at every step
  %           2 -> randomly selected partial gradient, 
  %                without regard to current active set ("unbiased")
  %
  % 'GradientFraction' = fraction of inactive gradient vector to evaluate
  %           In range (0,1]; ignored if FullGradient is 1.
  %           Default = 0.1.
  %
  % 'InitialAlpha' = initial value of alpha
  %            Default = 1.0.
  %
  % 'AlphaIncrease' = factor by which to increase alpha after descent not
  %                   obtained
  %            Default = 2.0.
  %
  % 'AlphaDecrease' = factor by which to decrease alpha after successful
  %                   first-order step
  %            Default = 0.8.
  %
  % 'AlphaMax' = maximum value of alpha; terminate with error if we exceed this
  %            Default = 1.e20
  %
  % 'c1' = parameter in range (0,1) defining the margin by which
  %        the first-order step is required to decrease before
  %        being taken. (The acceptance criterion is like the one
  %        defined in equation (22) of Wright, Figueiredo,
  %        Nowak. IEEE TSP 57 (2009), pp. 2479-2493, where c1 is
  %        denoted by sigma and we use M=0 for montonicity.)
  %            Default = 1.e-3
  %
  % 'MaxIter' = max number of iterations
  %            Default = min(10000, dimension of beta).
  %
  % 'StopTol' = convergence tolerance for target value of lambda
  %            Default = 1e-6
  %
  % 'IntermediateTol' = convergence tolerance for intermediate
  %                     values of lambda. (Ignored if accurateIntermediates=1.)
  %            Default = 1.e-4
  %
  % 'FinalOnly' = request output at final (target) value of lambda only.
  %          0 -> return information for all intermediate values also (default)
  %          1 -> return information just for final lambda value
  %
  %
  % a global place to put (X,b):
  global Xmat;
  global Yvec; global Yp; global Ym;
  global rows;

  % need to construct the following if standardization is requested:
  %
  % mu_vec:     vector of length n containing mean features
  % sigma_vec:  vector of length n containing standard deviations of
  %             features, except that the zero standard deviations are
  %             replaced by nonzero values (but their locations are 
  %             tabulated in sigma_zeros)
  % sigma_zeros: contains indices of the features with zero standard
  %             deviation
  % standardized: flag is set to 0 if no standardization is used, 1 if
  %             standardization is used. Defined internally and must be set
  %             via optional input "Standardize"

  global standardized;
  global sigma_vec;
  global sigma_zeros;
  global mu_vec;

  % value of lambda and problem dimensions stored in global structures, for
  % convenience.
  global lambda_global;
  global sampsize;
  global nbeta;
  
  Xmat = X; Yvec = b;  
  rowsX=size(X,1); colsX=size(X,2);
  % add one more component to the unknown vector beta, because of extra
  % column of ones, representing the constant shift.
  nbeta = colsX+1;
  
  % assume there will be no problems with convergence
  err = 0;
  
  % set defaults for optional inputs
  row_sample=1:rowsX;
  verbosityLevel = 0;
  standardized = 0;
  useContinuation = 0;
  initialLambda = 1.0;
  continuationSteps = 10;
  accurateIntermediates = 0;
  NI = 1;
  useNewton = 0;
  newtonThreshold = 500;
  hessianFrac = 1.0;
  useBB = 0;
  forceMontone = 1;
  GradientStrategy = 1;
  tau = 0.1;
  alpha = 1.0;
  alphaIncr = 2.0;
  alphaDecr = 0.8;
  alphaMax = 1.e20;
  c1 = 1.e-3;
  maxiter = min(nbeta,10000);
  tol = 1.e-6;
  intermediate_tol = 1.e-4;
  final_only = 0;
  
  % parse the optional inputs
  if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
  end
  for i=1:2:(length(varargin)-1)
    switch upper(varargin{i})
     case'SAMPLE'
      if prod(size(varargin{i+1})) > 1   % an array of indices
        row_sample = varargin{i+1};
        row_sample = sort(row_sample);
      elseif (varargin{i+1}==0) | (varargin{i+1}==1)
        row_sample = 1:rowsX;
      else % a scalar in the range (0,1)
        row_sample = find(rand(rowsX,1)<varargin{i+1});
        row_sample = sort(row_sample);
      end
     case 'INITIALIZATION'
      if prod(size(varargin{i+1})) > 1   % we have an initial beta, use it!
        beta_init = varargin{i+1};
      else % initialize at zero
        beta_init = zeros(nbeta,1);
      end
     case 'VERBOSITY'
      verbosityLevel = varargin{i+1};
     case 'STANDARDIZE'
      standardized = varargin{i+1};
     case 'CONTINUATION'
      useContinuation = varargin{i+1};
     case 'INITIALLAMBDA'
      initialLambda = varargin{i+1};
     case 'CONTINUATIONSTEPS'
      continuationSteps = varargin{i+1};
     case 'ACCURATEINTERMEDIATES'
      accurateIntermediates = varargin{i+1};
     case 'PRINTFREQ'
      NI  = max(varargin{i+1},1);
     case 'NEWTON'
      useNewton = varargin{i+1};
     case 'NEWTONTHRESHOLD'
      newtonThreshold = varargin{i+1};
     case 'HESSIANSAMPLEFRACTION'
      hessianFrac = varargin{i+1};
     case 'BB'
      % ignore this input, for now.
      %	useBB = varargin{i+1};
     case 'MONOTONE'
      % ignore this input, for now.
      % forceMonotone = varargin{i+1};
     case 'FULLGRADIENT'
      GradientStrategy = varargin{i+1};
     case 'GRADIENTFRACTION'
      tau = varargin{i+1};
     case 'INITIALALPHA'
      alpha = varargin{i+1};
     case 'ALPHAINCREASE'
      alphaIncr = varargin{i+1};
     case 'ALPHADECREASE'
      alphaDecr = varargin{i+1};
     case 'ALPHAMAX'
      alphaMax = varargin{i+1};
     case 'C1'
      c1 = varargin{i+1};
     case 'MAXITER'
      maxits = varargin{i+1};
     case 'STOPTOL'
      tol = varargin{i+1};
     case 'INTERMEDIATETOL'
      intermediate_tol = varargin{i+1};
     case 'FINALONLY'
      final_only = varargin{i+1};
    end
  end

  % Move the row indices used in this sample to a global varaible
  rows=row_sample;
  % Index vectors for positive and negative examples
  Yp=find(Yvec(rows)==1); Ym=find(Yvec(rows)==-1);
  
  % define sampsize to be the number of samples actually used
  sampsize = length(row_sample);
  if verbosityLevel>=1
    fprintf(' Sampled %d points out of %d\n', ...
            length(row_sample), rowsX);
    fprintf(' (%d positive samples, %d negative samples)\n', length(Yp), ...
            length(Ym));
  end

  % allow nonmonotone method only if BB steps are being calculated
  % if useBB ~= 1
  %   forceMonotone=1;
  % end
  
  % calculate sigma_vec and mu_vec (std deviations and means, used if we
  % are standardizing the observation matrix).
  if standardized==1
    [sigma_vec, sigma_zeros, mu_vec] = calculateSigmaMu(X,rows);
  end
  
  % determine lambda_max for this problem, as defined in "An
  % Interior-Point Method for Large-Scale l1-Regularized Logistic
  % Regression" by Koh, Kim, Boyd, JMLR 8 (2007), pp. 1519-1555.
  [lambda_max,intercept] = calculateLambdaMax();
  fprintf(1,' computed value of lambda_max: %9.4e\n',lambda_max);
  if lambda_max<= 0.0
    fprintf(1,[' *** ERROR: lambda_max = 0. (Possibly all points are ' ...
               'in the same class)\n']);
    return;
  end
  
  % if no continuation, make just one call to rlogreg, passing all the
  % input arguments on.
  
  if (useContinuation==0) | (initialLambda<=lambda_fac)
    times=cputime;
    lambda_input = lambda_fac * lambda_max;
    [beta, loglike, Tlambda, numNonzeros, iterations, err, ...
     alpha_final, nfunc, ngrad] = ...
	rlogreg(lambda_input, ...
                'Initialization', beta_init, ...
                'AdjustInitial', 0, ...
                'Verbosity', verbosityLevel, ...
                'Standardize', standardized, ...
                'printFreq', NI,...
                'Newton', useNewton, ...
                'NewtonThreshold', newtonThreshold, ...
                'HessianSampleFraction', hessianFrac, ...
                'FullGradient', GradientStrategy, ...
                'gradientFraction', tau,...
                'InitialAlpha', alpha, ...
                'alphaIncrease', alphaIncr, ...
                'alphaDecrease', alphaDecr, ...
                'alphaMax', alphaMax, ...
                'MaxIter', maxits, ...
                'StopTol', tol);
    times = cputime-times;
    lambda_seq = lambda_input;
    % if standardization used, need to transform beta into original
    % formulation
    if standardized==1
      beta_standard=beta;
      beta = unstandardizeBeta(beta_standard);
    end
    return;
  end
  
  % From here on, we're setting up for continuation. First, determine
  % the schedule of lambda values, defined to have equal geometric
  % spacing between the initial and target values of lambda.
  
  lambdas = zeros(continuationSteps+1,1);
  lambdas(1) = initialLambda * lambda_max;
  lambdas(continuationSteps+1) = lambda_fac * lambda_max;
  factor = log(initialLambda/lambda_fac) / continuationSteps;
  factor = exp(factor);
  for i=2:continuationSteps
    lambdas(i) = lambdas(i-1) / factor;
  end

  times(1) = 0;
  % set up initial beta to use optimal intercept calculated in
  % calculateLambdaMax()
  beta_init=zeros(nbeta,1); beta_init(nbeta)=intercept;
  % now go into the loop
  for k=1:continuationSteps+1
    time_k=cputime;
    lambda_input = lambdas(k);
    
    % solve it loosely or tightly on this iteration?
    if k<=continuationSteps & accurateIntermediates==0
      thisTol = intermediate_tol;
    else
      thisTol = tol;
    end
    
    [beta_k, loglike_k, Tlambda_k, numNonzeros_k, iterations_k, ...
     err, alpha_k, nfunc_k, ngrad_k] = ...
	rlogreg(lambda_input, ...
                'Initialization', beta_init, ...
                'AdjustInitial', 0, ...
                'Verbosity', verbosityLevel, ...
                'Standardize', standardized, ...
                'printFreq', NI,...
                'Newton', useNewton, ...
                'NewtonThreshold', newtonThreshold, ...
                'HessianSampleFraction', hessianFrac, ...
                'FullGradient', GradientStrategy, ...
                'gradientFraction', tau,...
                'InitialAlpha', alpha, ...
                'alphaIncrease', alphaIncr, ...
                'alphaDecrease', alphaDecr, ...
                'alphaMax', alphaMax, ...
                'MaxIter', maxits, ...
                'StopTol', thisTol);
    time_k = cputime-time_k;
    
    % use final beta as the initializer for the next iteration
    beta_init = beta_k;
    % also use the final alpha as the starter for the next iteration
    alpha=alpha_k;

    if final_only==1    % add time for this latest step
      times(1) = times(1) + time_k;
      if k==continuationSteps+1    % transfer values for return
        if standardized==1
          beta_standard = beta_k;
          beta=unstandardizeBeta(beta_standard);
        else          
          beta = beta_k;
        end
	lambda_seq = lambda_input;
	loglike = loglike_k;
	Tlambda = Tlambda_k;
	numNonzeros = numNonzeros_k;
	iterations = iterations_k;
        nfunc = nfunc_k;
        ngrad = ngrad_k;
      end
    else % we want results from all iterations
      times(k) = time_k;
      if standardized==1
        beta_standard = beta_k;
        beta(:,k)=unstandardizeBeta(beta_standard);
      else          
        beta(:,k) = beta_k;
      end
      lambda_seq(k) = lambda_input;
      loglike(k) = loglike_k;
      Tlambda(k) = Tlambda_k;
      numNonzeros(k) = numNonzeros_k;
      iterations(k) = iterations_k;
      nfunc(k) = nfunc_k;
      ngrad(k) = ngrad_k;
    end
    
    if err ~= 0
      return;
    end
  end
  return;

    
