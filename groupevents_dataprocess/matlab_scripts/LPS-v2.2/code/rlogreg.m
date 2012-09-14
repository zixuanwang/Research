function [beta, loglike, Tlambda, numNonzeros, iterations, err, alpha, nfunc, ngrad] = ...
    rlogreg(lambda_input, varargin)
  %
  % Minimize an l1-regularized logistic regression function.
  %
  % SJW 4/8/10, based on code by W. Shi and S. Wright.  
  %
  % Originally implemented the algorithm described in W. Shi,
  % G. Wahba, S. Wright, K. Lee, R. Klein, and B. Klein,
  % "LASSO-Patternsearch algorithm with application to opthalmology
  % data," Statistics and its Interface 1 (2008), pp. 137--153.
  %
  % Modified by SJW 8/10/10 to implement the algorithm in
  % S. J. Wright, "Accelerated block-coordinate relaxation for
  % regularized optimization," Technical Report, August 2010.
  %
  % Modified by SJW 8/25/11 to allow warm starts to be calculated by
  % doing Newton-like steps on the set of nonzeros provided in
  % beta_init
  % 
  % =======
  % compulsory input:
  % 
  % lambda_input: the regularization parameter (positive real) 
  % 
  % =======
  % outputs:
  %
  % beta:         final value of parameter vector
  % loglike:      logistic regression function at final beta
  % Tlambda:      regularized logistic regression function at final beta
  % numNonzeros:  number of nonzeros in the final beta
  % iterations:   iterations required
  % err:          0 for successful termination; 1 if AlphaMax
  %               exceeded; 2 if MaxIter exceeded.
  % alpha:        final value of damping parameter alpha
  % 
  % 
  % ===============
  % optional inputs:
  %
  % 'Initialization' must be one of {0,array}
  %            0 -> Initialize at beta=0
  %        array -> use this argument as the initial beta. Note that the
  %                 use or non-use of standardization should be taken into
  %                 account in setting beta.
  %            Default = 0.
  %
  % 'AdjustInitial' = adjust initial beta using Newton-like steps
  %                   on the current set of nonzeros? (Ignored if
  %                   Initialization=0)
  %            0 -> don't do adjustment
  %            1 -> do adjustment (default)
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
  %            0 -> don't force monotonicity - only allowed if BB=1
  %            1 -> force monotonicity (default)
  %            (NOT CURRENTLY USED)
  %
  % 'FullGradient' = use full gradient vector
  %           0 -> use randomly selected gradient subvector
  %           including current nonzero set (default)
  %           1 -> use full gradient vector at every step
  %           2 -> use randomly selected gradient subvector without
  %           including current nonzero set
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
  % 'AlphaMin' = minimum value of alpha; strictly positive.
  %            Default = 1.e-3
  %
  % 'MaxIter' = max number of iterations
  %            Default = min(10000, dimension of beta).
  %
  % 'StopTol' = convergence tolerance
  %            Default = 1e-6
  %
  %
  % ===============
  % implicit inputs:
  %
  % the main data for the problem is passed via global structures.
  %
  % Xmat : matrix of dimension m x n, where m is number of samples and n is
  %        number of features. 
  %
  % Yvec : vector of labels +/-1, dimension m, 
  %
  % if standardization is used (see optional input "Standardize"), the
  % following structure are assumed to be present
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

  global Xmat;
  global Yvec;
  global rows;
  global hessianFraction;
  
  % expose Fvector, which is computed in Functions() and
  % subsequently used in Gradient() and Hessian()
  global Fvector;
  
  global standardized;
  global sigma_vec;
  global sigma_zeros;
  global mu_vec;
  
  % value of lambda and problem dimensions stored in global structures,
  % for convenience.
  global lambda_global;
  global sampsize;
  global nbeta;
  
  % get size of observation matrix
  [rowsX colsX] = size(Xmat); 
  
  % set defaults for optional inputs
  adjustInitial = 1;
  verbosityLevel = 0;
  lambda_interpretation = 0;
  standardized = 0;
  NI = 1;
  useNewton = 0;
  two_metric_threshold = 500;
  hessianFrac = 1.0;
  useBB = 0;
  forceMonotone = 1;
  alpha = 1.0;
  alphaIncr = 2.0;
  alphaDecr = 0.8;
  alphaMax = 1.e20;
  alphaMin = 1.e-3;
%  c1 = 1.e-3;
  maxits = min(nbeta,10000);
  tol = 1.e-6;
  
  %--------------------------------------------------------------------------
  % parameters to control randomized evaluation:
  % FullGrad = set to 1 if we always evaluate full gradient. (tau and
  %                evalFullGrad are ignored when this is set.)
  % tau = fraction of random gradient components to evaluate for zero
  %         components of beta.
  %--------------------------------------------------------------------------
  FullGrad = 0;
  tau = 0.1;
  
  % assume that normal (successful) termination will occur
  err = 0;
  
  % parse the optional inputs
  if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
  end
  for i=1:2:(length(varargin)-1)
    switch upper(varargin{i})
     case 'INITIALIZATION'
      if prod(size(varargin{i+1})) > 1   % we have an initial beta, use it!
	beta_init = varargin{i+1};
      else % initialize at zero
	beta_init = zeros(nbeta,1);
      end
     case 'ADJUSTINITIAL'
      adjustInitial = varargin{i+1};
     case 'VERBOSITY'
      verbosityLevel = varargin{i+1};
     case 'STANDARDIZE'
      standardized = varargin{i+1};
     case 'PRINTFREQ'
      NI  = max(varargin{i+1},1);
     case 'NEWTON'
      useNewton = varargin{i+1};
     case 'NEWTONTHRESHOLD'
      two_metric_threshold = varargin{i+1};
     case 'HESSIANSAMPLEFRACTION'
      hessianFrac = varargin{i+1};
     case 'BB'
      % ignore this input, for now.
      % useBB = varargin{i+1};
     case 'MONOTONE'
      % ignore this input, for now.
      % forceMonotone = varargin{i+1};
     case 'FULLGRADIENT'
      FullGrad = varargin{i+1};
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
     case 'ALPHAMIN'
      alphaMin = varargin{i+1};
%     case 'C1'
%      c1 = varargin{i+1};
     case 'MAXITER'
      maxits = varargin{i+1};
     case 'STOPTOL'
      tol = varargin{i+1};
    end
  end
  
  % set adjustInitial to 0 if no initial beta was supplied
  if norm(beta_init)==0
    adjustInitial=0;
  end

  % store the Hessian sample fraction as a global variable. Restrict it
  % to the range [.01,1].
  hessianFraction = hessianFrac;
  if hessianFraction>1
    hessianFraction=1;
  elseif hessianFraction<.01
    hessianFraction=.01;
  end
  
  % allow nonmonotone method only if BB steps are being calculated
  % if useBB ~= 1
  %   forceMonotone=1;
  % end
  
  % transfer the input value of lambda to global storage
  lambda_global=lambda_input;
  
  
  % initialize function and gradient evaluation counters
  nfunc = 0;
  ngrad = 0;

  % initialize beta to beta_init - may be adjusted in the procedure
  % below
  beta = beta_init;
  
  %--------------------------------------------------------------------------
  % evalFullGrad = flag indicating whether full gradient should be evaluated.
  %   Turned on when gpnorm drops below tol. (Always turn it on if
  %   alwaysFullGrad is set.)
  %--------------------------------------------------------------------------
  evalFullGrad = 0;
  if FullGrad==1
    evalFullGrad = 1;
  end
  
  %--------------------------------------------------------------------------
  % Initial adjustment of nonzero components (and the intercept) in
  % the supplied starting point, using Newton's method
  %--------------------------------------------------------------------------
  
  if adjustInitial==1
    % find the current nonzeros in beta, excluding the intercept,
    % for the moment
    beta_nz = find(beta); beta_nz=setdiff(beta_nz,[nbeta]);
    red_beta=beta(beta_nz);
    % locate the positive and negative components, and set offsets
    % accordingly
    beta_nz_pos=find(red_beta>0);
    beta_nz_neg=find(red_beta<0);
    redGradOffset=zeros(length(red_beta),1);
    redGradOffset(red_beta>0)=lambda_global;
    redGradOffset(red_beta<0)=-lambda_global;
    % now add the intercept to the reduced structures, setting its
    % offset value to zero;
    beta_nz=[beta_nz;nbeta];
    red_beta=[red_beta;beta(nbeta)];
    redGradOffset=[redGradOffset;0];
    % set the full beta to all zeros
    beta=zeros(nbeta,1);
    % set max for number of inner iterations
    maxits_inner_adjust=10;
    maxits_outer_adjust=10;
    % initialize control variables for the inner loop
    iter_adjust=0;
    loop_adjust=1;
    % loop
    while (iter_adjust < maxits_outer_adjust) & (loop_adjust==1)
      iter_adjust = iter_adjust+1;
      % evaluate gradient
      beta(beta_nz)=red_beta;
      % have to call Functions() first to compute Fvector
      Tlambda_dummy = Functions(beta, lambda_global); 
      nfunc = nfunc+1;
      % compute the reduced gradient
      redGrad = Gradient(beta, beta_nz);
      ngrad=ngrad+(length(beta_nz)/nbeta);
      redGrad = redGrad+redGradOffset;
      gpnorm = norm(redGrad);
      if verbosityLevel>=3
        fprintf(1,' adjustment loop %d, gpnorm=%9.3e\n', iter_adjust, ...
                gpnorm);
      end
      if gpnorm<tol
        break;
      end
      % evaluate sampled Hessian 
      partialHessian  = Hessian(beta,beta_nz);
      % intialize damping parameter
      damping = gpnorm;
      % loop with increasing damping until we get a decrease in objective,
      % and no zero crossing
      for iter_inner=1:maxits_inner_adjust
        red_beta_step = -(partialHessian + damping*eye(length(beta_nz))) ...
            \ redGrad;
        red_beta_next = red_beta + red_beta_step;
        % check for sign changes (zero crossings) in the nonzero variables
        red_beta_stripped = red_beta(1:length(red_beta)-1);
        red_beta_next_stripped = red_beta_next(1:length(red_beta_next)-1);
        if sum((red_beta_next_stripped.*red_beta_stripped)<0) == 0
          % no crossings detected. check for gradient decrease
          beta(beta_nz) = red_beta_next;
          Tlambda_dummy = Functions(beta, lambda_global); nfunc = nfunc+1;
          redGrad_next = Gradient(beta, beta_nz);
          ngrad=ngrad+(length(beta_nz)/nbeta);
          redGrad_next = redGrad_next + redGradOffset;
          gpnorm_next = norm(redGrad_next);
%          fprintf(1,' gpnorm=%8.2e\n', gpnorm_next);
          if gpnorm_next < gpnorm
            red_beta = red_beta_next;
            break;
          end
        end
        % still here? increase damping
        damping = 4*damping;
      end
      % did inner iteration fail? If so, declare failure of the
      % adjustment strategy and set beta to the given beta_init
      if iter_inner==maxits_inner_adjust
        beta = beta_init;
        % set loop_adjust to 0 to force it to jump out of the outer
        % loop too.
        loop_adjust=0;
        if verbosityLevel>=0
          fprintf(1,'\nADJUSTMENT FAILED for lambda=%8.2e: gpnorm=%8.2e, ngrad=%8.2f\n', ...
                  lambda_global, gpnorm, ngrad);
          fprintf(1,'Reverting to the supplied initial value of beta\n');
        end        
        break;
      end
    end
    if verbosityLevel>=2
      fprintf(1,'\nafter adjustment at lambda=%8.2e: gpnorm=%8.2e, ngrad=%8.2f\n', ...
            lambda_global, gpnorm, ngrad);
    end
    
  end
  
  % Prepare for main loop: initialize iteration counter
  iter = 0; %gpnorm = 1.0;
  
  Tlambda = Functions(beta, lambda_global); nfunc=nfunc+1;
  beta_step=zeros(nbeta,1);   % initialize beta_step;
  loop_on=1;                  % set to zero to stop the loop

  if verbosityLevel>=1
    nz=length(find(beta(1:nbeta)~=0));
    fprintf('\n **** Initial point: nz=%d, f= %15.12g, lambda=%10.3e\n', ...
            nz, Tlambda, lambda_global);
  end
  

  %--------------------------------------------------------------------------
  % Start of main loop
  %--------------------------------------------------------------------------
  while (iter<maxits) && (loop_on==1)
    iter = iter+1;
    
    % initialize beta_new to be the current beta (subsequently, some of
    % its entries will be modified by the step)
    beta_new=beta;      			    
    
    %----------------------------------------------------------------------
    % evaluate either the full gradient, or a partial gradient for the
    % following components: (i) the current nonzero indices and (ii) a
    % fraction "tau" of the other indices. The indices to be evaluated
    % are stored in "beta_inx"
    %----------------------------------------------------------------------
    if (evalFullGrad==1) | (FullGrad==1)
      beta_inx=1:nbeta;
    else
      beta_nz   = find(beta);
      beta_rand = find(rand(nbeta,1)<tau);
      % include the current nonzero set if FullGrad==0
      if FullGrad==0
        beta_inx = union(beta_nz,beta_rand);
      else
        beta_inx = beta_rand;
      end
      % always include the last (unregularized) component of beta
      beta_inx = union(beta_inx,[nbeta]);
    end
    beta_inx_complement = setdiff([1:nbeta],beta_inx)';
    
    Grad = zeros(nbeta,1);
    Grad(beta_inx) = Gradient(beta, beta_inx);
    ngrad=ngrad+(length(beta_inx)/nbeta);
    
    %----------------------------------------------------------------------
    % Evaluate subgradient of minimal norm. 
    %----------------------------------------------------------------------
    subGradMin = Grad - lambda_global*(beta<0) + lambda_global*(beta>0);
    km = find(beta==0 & Grad<=0);
    kp = find(beta==0 & Grad> 0);
    subGradMin(km) = min(0,Grad(km)+lambda_global);
    subGradMin(kp) = max(0,Grad(kp)-lambda_global);
    % there's no nonsmooth term for last component, so leave it alone
    subGradMin(nbeta) = Grad(nbeta);  
    % make sure that the entries of subGradMin corresponding to all
    % *non-evaluated* components of Grad are set to zero
    subGradMin(beta_inx_complement) = 0.0;
    % calculate a (possibly partial) subgradient norm.
    gpnorm = norm(subGradMin);
    
    %----------------------------------------------------------------------
    % find the set of nonzeros for the current beta
    %----------------------------------------------------------------------
    InonZero0 = find(beta);
    InonZero0 = union(InonZero0, [nbeta]);
    InonZero0_complement = setdiff([1:nbeta],InonZero0)';        
    numNonZero0 = length(InonZero0);
    
    % print out information every NI-th iteration (NI supplied via the
    % option 'PrintFreq'
    if ((mod(iter,NI)==0) & (verbosityLevel>=1)) | (loop_on==0)
      fprintf('iter %4d, gpnorm=%8.4e, nonzero=%4d (%5.1f%%), function=%15.12e, alpha=%10.4e\n', ...
              iter, gpnorm, numNonZero0, ...
              100*numNonZero0/nbeta,Tlambda, alpha);
    end
    
    if gpnorm<tol
      if (evalFullGrad==1) | (FullGrad==1)
        %       if partialHessian
        % 	fprintf(' condition of final projected Hessian = %6.2e\n', ...
        % 	    cond(partialHessian));
        %       end
        break                 % break if convergence test is met
      else
        evalFullGrad=1;       % evaluate full gradient on next iteration
      end
    else 
      % minimum subgradient norm is above tolerance, so turn off full grad
      % evaluation
      evalFullGrad=0;  
    end
    
    %----------------------------------------------------------------------
    % Calculate the first-order step
    %----------------------------------------------------------------------
    betaGrad = Grad - alpha*beta;
    % k0 = find(betaGrad>=-lambda_global & betaGrad<=lambda_global);
    kn = find( betaGrad< -lambda_global); 
    kn = setdiff(kn, beta_inx_complement);
    kp = find( betaGrad>  lambda_global);
    kp = setdiff(kp, beta_inx_complement);
    k0 = setdiff(beta_inx, union(kn,kp));
    beta_new(k0) = 0;
    beta_new(kn) = beta(kn) - (Grad(kn)+lambda_global)/alpha;
    beta_new(kp) = beta(kp) - (Grad(kp)-lambda_global)/alpha;
    % last component has no nonsmooth term, so treat differently.
    beta_new(nbeta) = beta(nbeta) - Grad(nbeta)/alpha;
    % the components for which gradient was not evaluated are set
    % to their current values
    beta_new(beta_inx_complement) = beta(beta_inx_complement);
    % calculate the step by taking a difference
    beta_step_first = beta_new-beta;
    % calculate decrease margin required for acceptance of the step.
    beta_step_first_norm = norm(beta_step_first);
    sufficientDecreaseMargin = 2*beta_step_first_norm^3;
    
    %----------------------------------------------------------------------
    % Find subspace identified by the first-order step
    %----------------------------------------------------------------------
    InonZero=find(beta_new);
    InonZero=union(InonZero,nbeta);
    numNonZero = length(InonZero);
    InonZero_complement = setdiff([1:nbeta],InonZero)';
    InonZero_diff = setxor(InonZero0,InonZero);
    numNonZero_diff = length(InonZero_diff);
    
    %----------------------------------------------------------------------
    % evaluate the function at the first-order point.
    %----------------------------------------------------------------------
    Tlambda_first = Functions(beta_new, lambda_global); nfunc=nfunc+1;
    %----------------------------------------------------------------------
    % check for sufficient decrease
    %----------------------------------------------------------------------
    if (Tlambda_first > Tlambda-sufficientDecreaseMargin)
      % insufficient decrease - increase alpha for next attempt.
      alpha = alphaIncr*alpha;
      if alpha > alphaMax
        fprintf(1,' alpha=%e, alphaMax=%e\n', alpha, alphaMax);
        err = 1;  % signal error termination
        loop_on = 0;
      end
    else
      % take first-order step and decrease alpha for next iteration
      alpha = alphaDecr*alpha;
      if alpha < alphaMin
        alpha = alphaMin;
      end
      Tlambda_new = Tlambda_first;
      beta = beta_new;
      % if requested, look for enhancement
      newtonSuccess=0;
      if (useNewton==1) && ...
            (length(InonZero)<=two_metric_threshold) 
        %            (numNonZero_diff <= max(3, 0.2*max(numNonZero,numNonZero0)))
        % calculate reduced gradient
        Grad = zeros(nbeta,1);
        Grad(InonZero) = Gradient(beta, InonZero);
        ngrad=ngrad+(length(InonZero)/(nbeta+1));
        
        reducedGradient = Grad - lambda_global*(beta<0) + ...
            lambda_global*(beta>0); 
        % special treatment for last component
        reducedGradient(nbeta) = Grad(nbeta);
        % shrink it to just the nonzeros
        reducedGradient = reducedGradient(InonZero);
        % evaluate the partial Hessian corresponding to these nonzero
        % components.
        partialHessian  = Hessian(beta, InonZero);
        % add a damping term to deal with ill-conditioned reduced Hessians
        % (which happens often)
        % scale_factor = mean(diag(partialHessian));      
        %      damping = min(0.25*scale_factor, 10.0*gpnorm);
        damping = 10*gpnorm;
        % assemble the enhanced step from the partial Newton step and
        % the first-order step.
        beta_step(InonZero) = ...
            -(partialHessian + damping*eye(length(InonZero))) ...
            \ reducedGradient;
        beta_step(InonZero_complement) = 0.0;
        
        %------------------------------------------------------------------
        % detect the components that cross zero in the full Newton step
        %------------------------------------------------------------------
        beta_newton=zeros(nbeta,1);
        % take the line-search Newton step in the nonzero components;
        beta_newton(InonZero) = beta(InonZero) + beta_step(InonZero);
        % set to zero those components that appear to be zero in the
        % first-order subproblem
        beta_newton(InonZero_complement)=0;
        % find the indices for which this Newton step causes a change in sign
        iCrossings=(beta_newton.*beta<0);
        % exclude the final component from consideration
        iCrossings(nbeta)=0;
        % count up the number of sign changes.
        findCrossings=find(iCrossings==1);
        numCrossings=sum(iCrossings);
        %----------------------------------------------------------------------
        % If there were sign changes in the full Newton step, rescale
        % the step to stop at the first kink.  Evaluate function and
        % check for decrease over the step from the first-order model.
        %----------------------------------------------------------------------
        newtonStepLength = 1;
        if numCrossings>0
          newtonStepLength = ...
              min( abs(beta(findCrossings)) ./ ...
                   (abs(beta_step(findCrossings))) );
        end
        
        % if permissible step length along Newton direction too
        % short, don't bother trying it
        newtonStepLengthThreshold = 1.e-2;
        if newtonStepLength <= newtonStepLengthThreshold
          % just take first-order step
          Tlambda = Tlambda_new;
          if verbosityLevel>=2
            fprintf(1,' Newton step REJECTED: too short: %6.2e\n', ...
                    newtonStepLength);
          end
        else
          % try the truncated Newton step
          beta_newton(InonZero) = ...
              beta(InonZero)+newtonStepLength*beta_step(InonZero);
          beta_newton(InonZero_complement)=0;
          
          
          % evaluate function and check acceptability
          Fvector_saved = Fvector;
          Tlambda_newton = Functions(beta_newton, lambda_global);
          nfunc=nfunc+1;
          beta_step_norm = norm(beta_step);
          Tlambda_threshold =  Tlambda - 1.e-3*(newtonStepLength*beta_step_norm)^3;
          if (Tlambda_newton <= Tlambda_new) & ...
                (Tlambda_newton <= Tlambda_threshold)
            if verbosityLevel>=2
              fprintf(1,' Newton step of length %6.2e ACCEPTED\n', ...
                      newtonStepLength);
            end
            % update variable vector and current function value
            beta_new = beta_newton;
            beta = beta_new;
            Tlambda = Tlambda_newton;
            newtonSuccess=1;
          else
            % restore Fvector
            Fvector = Fvector_saved;
            % update Tlambda, since the first-order step was
            % successful, even though the accelerated step failed.
            Tlambda = Tlambda_new;
            if verbosityLevel>=2
              fprintf(1,' Newton step of length %6.2e REJECTED\n', ...
                      newtonStepLength);
              fprintf(1,[' T_first-T_newton=%16.10e, T_threshold-' ...
                         'T_newton=%16.10e\n'], Tlambda_new-Tlambda_newton, ...
                      Tlambda_threshold-Tlambda_newton);  
            end
          end
        end
      else
        % come here if the first-order step was successful, but
        % we didn't try the Newton step. In this case too, need
        % to update Tlambda.
        Tlambda = Tlambda_new;
      end
    end
    
    % re-evaluate function (* could code more carefully to save this
    % evaluation in some cases. For example, when the newton step is
    % computed but fails to improve on first-order step, we need to
    % re-evaluate to load the global data structures with information
    % reflecting the current point. *)
    % Tlambda = Functions(beta, lambda_global); 
    % nfunc=nfunc+1;
    
  end % end the main loop
  
  if iter>=maxits
    err = 2;  % signal error termination
  end    
  
  % re-evaluate final function and set outputs
  [Tlambda, loglike] = Functions(beta, lambda_global);
  nfunc=nfunc+1;
  numNonzeros = numNonZero0;
  iterations = iter;
  
  % print out some final stats
  if verbosityLevel>=1
    fprintf(1,' Function evals = %d,  Gradient evals = %10.1f\n', ...
            nfunc, ngrad);
  end
  
  