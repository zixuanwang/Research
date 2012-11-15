%this is the script to plot results
A = dlmread('logit_regression_results_noheader.txt');
cdfplot(A(:,4))
hold on
h = cdfplot(A(:,5));
hold off
set(h,'color','g');
hold on
h=cdfplot(A(:,7));
hold off
set(h,'color','r');
hold on
h = cdfplot(A(:,8));
hold off
set(h,'color','m')

hold on
h=cdfplot(A(:,10));
hold off
set(h,'color','black');
hold on
h = cdfplot(A(:,11));
hold off
set(h,'color','yellow')



legend('train:all features','test: all features','train:item features only','test:item features only','train:user features only','test:user features only')
xlabel('x = ratio of correctly predicted instances')

