%
% Logistic: calculate the logistic function of the input
%
function Output = Logistic(Input)
    Output = 1./(1+exp(-Input));
%EOF