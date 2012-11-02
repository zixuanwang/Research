N=1000;
K=50;
D=2;
T=100;

X = rand(D,N);

tic
[A M E] = kmeans(X, K, T);
toc

clf;
plot(X(1,:),X(2,:),'.g',M(1,:),M(2,:),'kx','LineWidth',15);
hold on;
h = voronoi(M(1,:),M(2,:));
for i=1:size(h,1);
  set(h(i),'LineWidth',3);
end;
hold off