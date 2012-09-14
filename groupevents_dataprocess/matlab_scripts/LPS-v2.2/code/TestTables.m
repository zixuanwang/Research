% Produces the tables of results reported in the paper
%
% S. J. Wright,  "Accelerated block-coordinate relaxation for
% regularized optimization," Technical report, August 2010. Revised
% August 2011
%
% SJW 4/19/10
% SJW 8/7/10
% SJW 8/24/11

% Requires definition of data files containing X and b, where X is the
% N x k matrix of N data points with k features and b is a vector of N
% binary labels, with values +/-1


% on the bigger data sets, test features such as gradient sampling,
% Hessian sampling, and sample-average approximation of the data set.

% target value of regularization parameter, as a multiple of the
% "max" value
lambda_fac = .25;

% number of steps in continuation heuristic
continuationSteps = 10;

% point to the input files for the tables in the paper. (Comment
% out all but one of the lines below.)

fname='../../data-shi/bigdata2.mat';
% fname='../../data-shi/bigdata11.mat';
% fname='../../data-shi/bigdata13.mat';

if exist(fname,'file')
  load(fname);
  
  % open an output file
  fid=fopen('TableOutput.txt','w');
  fprintf(fid,'Output for %s\n\n',fname);
  fprintf(fid,' regularization factor %5.2f\n', lambda_fac);
  fprintf(fid,' continuation steps %3d\n', continuationSteps);
  
  fprintf(fid,'|G|/m,  |S|/m,  nf,  ng,  CPU time, Qk strategy\n\n');
  
  nn=size(X,1);
  
  nSamples = 1; 
  fractionSample = 1.0; 
  
  gradientFractionArray = [1 .2 .05 .01];
  hessianSampleFracArray = [1 .2 .05 .01 0];
  GradientStrategyArray = [2 0];

  for gradientFraction = gradientFractionArray
    for hessianSampleFrac = hessianSampleFracArray
      strategyLoop=0;
      for GradientStrategy = GradientStrategyArray
        strategyLoop=strategyLoop+1;
        if gradientFraction >= 1.0
          % just solve it once when gradientFraction=1 - there is
          % no difference between strategies 0 and 2 in this case.
          if strategyLoop>1
            break;
          end
          GradientStrategyInput=1;
        else
          GradientStrategyInput=GradientStrategy;
        end
        
        % interpret hessianSampleFrac=0 to mean that we use a first-order
        % method (no Newton acceleration).
        if hessianSampleFrac==0
          Newton=0;
        else
          Newton=1;
        end
          
        % gather performance statistics over multiple trials.
        sampTime = [];
        sampFeval = [];
        sampGeval = [];
        
        for nS=1:nSamples
          fprintf(1,'\n\n ##### Problem %s\n\n', fname);
          fprintf(1,' ##### Sample %d (%5.2f), Gradient Frac %5.2f, Hessian Frac %5.2f, Strategy %2d\n\n', ...
                  nS, fractionSample, gradientFraction, hessianSampleFrac, ...
                  GradientStrategyInput); 
          fprintf(1,' calling lps with target lambda=%5.2f * lambda_max\n', ...
                  lambda_fac);
          
          [beta, lambda_seq, loglike, Tlambda, numNonzeros, iterations, err, times, nfunc, ngrad] = ...
              lps(lambda_fac, ...
                  X, ...
                  b, ...
                  'Sample', fractionSample, ...
                  'Initialization', 0, ...
                  'Verbosity', 0, ...
                  'Standardize', 0, ...
                  'Continuation', 1, ...
                  'continuationSteps', continuationSteps, ...
                  'Newton', Newton, ...
                  'HessianSampleFraction', hessianSampleFrac, ...
                  'FullGradient', GradientStrategyInput, ... 
                  'GradientFraction', gradientFraction, ...  
                  'InitialAlpha', 1.0, ...
                  'AlphaMax', 1.e25, ...
                  'MaxIter', 50000, ...
                  'StopTol', 1.e-6, ...
                  'IntermediateTol', 1.e-6);
          
          fprintf(1,'\n');
          fprintf(1,' Data set has %d vectors with %d features\n\n', size(X,1), ...
                  size(X,2));
          
          if err==1
            fprintf(1,' ****** ERROR: AlphaMax exceeded\n\n');
          elseif err==2
            fprintf(1,' ****** ERROR: MaxIter exceeded\n\n');
          end
          
          for k=1:length(times)
            fprintf(1,'lambda=%6.2e. nonzeros: %6d, iterations %5d, nfunc: %5d, ngrad: %7.1f, seconds: %7.2f\n', ...
                    lambda_seq(k), numNonzeros(k), iterations(k), nfunc(k), ...
                    ngrad(k), times(k));
          end
          
          fprintf(1,'\n\n');
          fprintf(1,' final lambda_fac: %7.3f\n', lambda_fac);    
          fprintf(1,' Continuation steps: %3d\n', continuationSteps);
          fprintf(1,' Gradient Strategy: %2d\n', GradientStrategyInput);
          fprintf(1,' Hessian sample frac: %5.2f\n', hessianSampleFrac);
          fprintf(1,' gradient sample frac: %5.2f\n', gradientFraction);
          fprintf(1,' Total function evaluations: %6d\n', sum(nfunc));
          fprintf(1,' Total gradient evaluations: %7.1f\n', sum(ngrad));
          fprintf(1,' Total time: %7.1f\n', sum(times));
          
          sampTime = [sampTime; sum(times)];
          sampFeval = [sampFeval; sum(nfunc)];
          sampGeval = [sampGeval; sum(ngrad)];
          
          % write a single line in the output file, in similar format to the
          % table reported in the paper
          fprintf(fid,' %5.2f,  %5.2f,  %5d,  %6.1f,  %6.1f',...
                  gradientFraction, hessianSampleFrac, sum(nfunc), ...
                  sum(ngrad), sum(times));
          if GradientStrategyInput==0
            fprintf(fid,' biased\n');
          elseif GradientStrategyInput==2
            fprintf(fid,' unbiased\n');
          elseif GradientStrategyInput==1
            fprintf(fid,' full\n');
          else
            fprintf(fid,' %d\n', GradientStrategyInput);
          end
          
        end
        
        if nSamples>1
          fprintf(1,' \n\nFinal statistics over %d trials.\n', nSamples);
          fprintf(1,' Data set has %d vectors with %d features\n\n', size(X,1), ...
                  size(X,2));
          fprintf(1,' final lambda_fac: %7.3f\n', lambda_fac);    
          fprintf(1,' Continuation steps: %3d\n', continuationSteps);
          fprintf(1,' Gradient Strategy: %2d\n', GradientStrategyInput);
          fprintf(1,' gradient sample frac: %5.2f\n', gradientFraction);
          fprintf(1,' Hessian sample frac: %5.2f\n', hessianSampleFrac);
          fprintf(1,' Average time: %7.1f\n', sum(sampTime)/nSamples);
          fprintf(1,' Average Function Evals: %7.1f\n', sum(sampFeval)/nSamples);
          fprintf(1,' Average Grad Evals: %7.1f\n', sum(sampGeval)/nSamples);
        end
      end
    end
  end
  fclose(fid);
else
  fprintf(1,' No input file found: %s\n', fname);
end

  
  
  