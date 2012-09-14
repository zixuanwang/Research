% calling program for lps.m
%
% SJW 5/8/10

% Requires definition of data files containing X and b, where X is the
% N x k matrix of N data points with k features and b is a vector of N
% binary labels, with values +/-1

% to run on fewer data sets, comment out some of the lines below
% that define entries of "fnames"

% UCI data sets, as formatted by Jianing Shi (Columbia)

clear fnames;
j=1; 
fnames{j}='../data/arrhythmia.mat';
j=j+1; fnames{j}='../data/glass.mat';
% 'horsecolic' has a poorly scaled design matrix - does not converge
% unless standardized (i.e. set the 'standardize' option to '1').
j=j+1; fnames{j}='../data/horsecolic.mat';
j=j+1; fnames{j}='../data/iono.mat';
j=j+1; fnames{j}='../data/madelon.mat';
j=j+1; fnames{j}='../data/pageblock.mat';
j=j+1; fnames{j}='../data/spambase.mat';
j=j+1; fnames{j}='../data/spectheart.mat';
j=j+1; fnames{j}='../data/wine.mat';

% data sets of Weiliang Shi 

j=j+1; fnames{j}='../data/data1.mat';
j=j+1; fnames{j}='../data/data2.mat';
j=j+1; fnames{j}='../data/data3.mat';
j=j+1; fnames{j}='../data/data4.mat';
j=j+1; fnames{j}='../data/data5.mat';

% define the target value of the regularization parameter lambda,
% expressed as a fraction of the "maximum" value.

% set an ambitious target value (mild regularization).

lambda_fac = 0.1;

for ifile=1:size(fnames,2)
  fname=fnames{ifile};
  if exist(fname,'file')
    load(fname);
    
    fprintf('\n\n ##### Problem %s\n\n', fname);
    fprintf(' calling lps with target lambda=%5.2f * lambda_max\n', ...
            lambda_fac);
    
    % use Hessian sampling with sample fraction given here. (1=evaluate
    % the exact reduced Hessian as required.)
    hessianSampleFrac = 1.0;
    
    [beta, lambda_seq, loglike, Tlambda, numNonzeros, iterations, err, times] = ...
        lps(lambda_fac, ...
            X, ...
            b, ...
            'Initialization', 0, ...
            'Verbosity', 0, ...
            'Standardize', 1, ...
            'Continuation', 1, ...
            'initialLambda', 1.0, ...
            'continuationSteps', 10, ...
            'Newton', 1, ...
            'HessianSampleFraction', hessianSampleFrac, ...
            'FullGradient', 0, ...  
            'GradientFraction', 0.1, ...          
            'InitialAlpha', 1.0, ...
            'MaxIter', 500, ...
            'StopTol', 1.e-6, ...
            'IntermediateTol', 1.e-6);
    
    fprintf('\n');
    fprintf(1,' Data set has %d vectors with %d features\n\n', size(X,1), ...
            size(X,2));
    
    if err==1
      fprintf(' ****** ERROR: AlphaMax exceeded\n\n');
    elseif err==2
      fprintf(' ****** ERROR: MaxIter exceeded\n\n');
    end
    
    for k=1:length(times)
      fprintf(1,'lambda=%6.2e solution has %6d nonzeros. It required %5d iterations and %7.2f seconds\n', ...
              lambda_seq(k), numNonzeros(k), iterations(k), times(k));
    end
    
    fprintf(' Total time: %6.2e\n', sum(times));
  end
end

% on this bigger data set, test features such as gradient sampling,
% Hessian sampling, and sample-average approximation of the data set.

if exist('../data/bigdata2.mat','file')
  fname='../data/bigdata2.mat';
  load(fname);
    
  nn=size(X,1);

  lambda_fac = 0.33;

  nSamples = 3; fractionSample = 0.5; 
  gradientFraction = 0.1;
  hessianSampleFrac = 0.2;

  
  for nS=1:nSamples
    fprintf('\n\n ##### Problem %s\n\n', fname);
    fprintf(' ##### Sample %d, Sample Frac %5.2f, Hessian Sample %5.2f\n\n', ...
            nS, fractionSample, hessianSampleFrac); 
    fprintf(' calling lps with target lambda=%5.2f * lambda_max\n', ...
            lambda_fac);
    
    [beta, lambda_seq, loglike, Tlambda, numNonzeros, iterations, err, times] = ...
        lps(lambda_fac, ...
            X, ...
            b, ...
            'Sample', fractionSample, ...
            'Initialization', 0, ...
            'Verbosity', 0, ...
            'Standardize', 0, ...
            'Continuation', 1, ...
            'initialLambda', 1.0, ...
            'continuationSteps', 20, ...
            'Newton', 1, ...
            'HessianSampleFraction', hessianSampleFrac, ...
            'FullGradient', 0, ... 
            'GradientFraction', gradientFraction, ...  
            'InitialAlpha', 1.0, ...
            'MaxIter', 1000, ...
            'StopTol', 1.e-6, ...
            'IntermediateTol', 1.e-6);
    
    fprintf('\n');
    fprintf(1,' Data set has %d vectors with %d features\n\n', size(X,1), ...
            size(X,2));
    
    if err==1
      fprintf(' ****** ERROR: AlphaMax exceeded\n\n');
    elseif err==2
      fprintf(' ****** ERORR: MaxIter exceeded\n\n');
    end
    
    for k=1:length(times)
      fprintf(1,'lambda=%6.2e solution has %6d nonzeros. It required %5d iterations and %7.2f seconds\n', ...
              lambda_seq(k), numNonzeros(k), iterations(k), times(k));
    end
    
    fprintf(' Total time: %6.2e\n', sum(times));
  end
  
end


  
  