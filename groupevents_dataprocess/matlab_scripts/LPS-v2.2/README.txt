LPS Version 2.2: 02 Sep 2011
============================

This version was issued alongside the revision of the paper [5].

Major Changes from Version 2.1:

* Solution for lambda = lambda_max calculated in closed form, and
  returned by the routine calculateLambdaMax.m

* When continuation option is selected, the initial value of the
  regularization parameter is set to lambda_max by default, and beta
  is initialized to the closed-form solution for this value. 

* New optional input "AdjustInitial" in rlogreg.m. When set to 1, a
  reduced Newton method is applied to the supplied initial value of
  beta, fixing the current zero components of beta at zero (except for
  the intercept term, which is always allowed to vary). (Default: 1)


LPS Version 2.1: 17 Jan 2011
============================

This version implements the algorithm described in the paper [5] which
is based on the method described in Appendix B of [1].

Several modifications appear in this version, including the following.

* rather than combining first-order and second-order information in
  different components of a single step (as in Version 1.x) we first
  calculate the step using partial first-order information (the
  "prox-step") and then optionally compute a reduced second-order step
  along the current active manifold (the "enhanced step"). The latter
  step is curtailed so as not to allow any nonzero components to cross
  from positive to negative.

* The enhanced step is computed only when the number of active
  components is sufficiently small. It is considered as a possible
  step only when it produces a sufficient decrease (see below) and
  when the curtailment above is not too severe.

* Use of "sufficient decrease" acceptance criteria both for the
  prox-steps (computed with only first-order information) and the
  enhanced steps (the steps actually taken).

* The reduced Hessian may be approximated (sampled) by using only a
  subset of the training points, as in [6].


SUBDIRECTORIES
==============

./code: contains matlab code (self-contained)
./data: contains test data for the smaller problems.

test data for the larger examples can be downloaded separately through
the web site.

MAIN ROUTINE lps.m
==================

The main routine lps.m calculates a decreasing sequence of parameters
lambda, ending at the target value specified by the user, and solves a
sequence of regularized logistic regression problems, using the
solution of each as a starting point for the next.  (This continuation
strategy is generally more efficient and reliable when solving for
small values of lambda than solving a single problem.)

lps.m requires the following three inputs:

lambda_fac: regularization parameter, expressed as a multiple of the
maximum value described in [2].

X:   m x n design matrix (m data points, n features)
b:   m vector with entries +1 or -1 indicating labels

There are a number of optional inputs to lps.m, documented in the
code.

Outputs from lps.m include:

beta: (n+1) x p matrix. Column j contains weights for each of the n
features (first n elements) plus a constant term (last element)
obtained by solving the regularized logistic regression problem for
the value lambda = lambda_seq(j) (see below). Given a feature vector
x, the odds implied by beta(:,j) are as follows:

probability of class +1:   1 / [1+exp(beta(1:n,j)*x+beta(n+1,j))]
probability of class -1:   1 -  1 / [1+exp(beta(1:n,j)*x+beta(n+1,j))]

lambda_seq: p-vector of lambda values visited by the continuation scheme
(if used), expressed as the actual value (NOT as a multiple of the
"maximum" lambda discussed above).

loglike: p-vector of the optimal log-likelihood function value
corresponding to lambda_seq

Tlambda: p-vector of the optimal *regularized* log-likelihood function
value corresponding to lambda_seq (includes the l-1 term).

numNonzeros: p-vector containing the number of nonzeros at the optimum
for each element of lambda_seq.

iterations: p-vector containing the number of iterations required by
the algorithm for each element of lambda_seq.

err: returns 0 if a solution was found; 1 if the value of damping
parameter alpha had to be increased above AlphaMax; 2 if the specified
iteration limit MaxIter was exceeded.

times: p-vector containing the seconds of CPU time required by the
algorithm for each element of lambda_seq.

STANDARDIZATION:
===============

By setting an input parameter to lps.m, standardization can be applied
implicitly to the matrix X (scaling and shifting each column so that
it has mean zero and variance 1) prior to performing the optimization. 

Default: no standardization.


OTHER ROUTINES:
==============

rlogreg.m: main routine that solves for a single value of lambda.

Functions.m, Gradient.m, Hessian.m: Routines to calculate function
value of regularized logistic regression objective, and gradient and
Hessian of the smooth part (excluding the regularization term).

M_mult.m, Mt_mult.m: routines to do matrix-vector multiplication by
the design matrix X or its transpose. Optionally and implicitly, it
can do these operations with the "standardized" versions of X.

calculateLambdaMax.m: calculates the "maximum" value of lambda (above
which the minimizer of the regularized problem has all weights zero),
described in [2].

calculateSigmaMu.m: if "standardization" is requested, this calculates
and stores the means and variances of each column of the design matrix
X.

standardizeBeta.m, unstandardizeBeta.m: converts the weight vector
beta between the standardized and non-standardized formulations.

Test.m: Routine to run lps.m on the data sets in the subdirectory
./data.

TestBig.m: Routine to run lps.m on larger data sets in addition to the
smaller sets in the subdirectory ./data.

TestTables.m: Routine to reproduce the data reported in the tables of
[5].

ProblemGenerator.m: Generates test problems such as those used in [5].

DATA:
====

Subdirectory ./data contains data files in matlab format for a number
of test problems. Each file contains X and b (described above).

Some files were used as test data in [3] and were kindly supplied by
Jianing Shi (Columbia). Others were used by Weiliang Shi during
development of this code.

RUNNING TESTS AND REPRODUCING TABLES FROM [5]:
=============================================

To reproduce the tables of [5], install the code, and download the
data sets bigdata2.mat, bigdata11.mat, and bigdata13.mat from the web
site.

Edit the definition of "fname" in TestTables.m to point to the
location of one of these files.

In Matlab, type "TestTables".

Adjust the optional argument "verbosity" to lps, to 1 or 2, if more
output is desired (but this may produce a LOT of output).

Adjust the definition of the arrays gradientFractionArray and
hessianSampleFracArray if you wish to try other values for these
parameters.

You can use TestBig.m in a similar fashion.

To run the small tests, edit Test.m appropriately. Data for these
tests is included in the distribution.

Main Changes from Version 2.0:

* fixed error in calculation of lambdaMax.

VERSION HISTORY
===============

Version 1.0, 4/19/2010
Version 1.1, 5/6/2010
Version 1.2, 5/8/2010
Version 2.0, 8/10/2010
Version 2.1, 1/17/2011

BIBLIOGRAPHY
============

[1] W. Shi, G. Wahba, S. J. Wright, K. Lee, R. Klein, and B. Klein,
"LASSO-Patternsearch Algorithm with Application to Ophthalmology and
Genomic Data," Statistics and its Interface 1 (2008), pp. 137-153.

[2] K. Koh, S.-J. Kim, and S. Boyd, "An Interior-Point Method for
Large-Scale l1-Regularized Logistic Regression," Journal of Machine
Learning Research 8 (2007), pp. 1519-1555.

[3] J. Shi, W. Yin, S. Osher, and P. Sajda, "A fast hybrid algorithm
for large scale l1-regularized logistic regression," Journal of
Machine Learning Research 11 (2010), pp. 713-741.

[4] S. J. Wright, R. Nowak, and M. A. T. Figueiredo, "Sparse
reconstruction via separable approximation," IEEE Transactions on
Signal Processing 57 (2009), pp. 2479-2403.

[5] S. J. Wright, "Accelerated block-coordinate relaxation for
regularized optimization," Technical Report, August 2010. Revised
September 2011.

[6] R. H. Byrd, G. M. Chin, W. Neveitt, and J. Nocedal, "On the use of
stochastic Hessian information in unconstrained optimization,"
Technical Report, Northwestern University, June 2010.
