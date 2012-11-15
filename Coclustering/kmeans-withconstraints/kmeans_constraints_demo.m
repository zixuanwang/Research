N=1000;

D=2;
T=100;
%X = rand(N,D);
% ground truth 
%GT = zeros(N,1);
%GT(find(X(:,1)<0.5 & X(:,2)<0.5))= 1;
%GT(find(X(:,1)>=0.5 & X(:,2)<0.5)) = 2;
%GT(find(X(:,1)<0.5 & X(:,2)>=0.5)) = 3;
%GT(find(X(:,1)>=0.5 & X(:,2)>=0.5)) = 4;

a = 5*[randn(500,1)+5, randn(500,1)+5];
b = 5*[randn(500,1)+5, randn(500,1)-5];
c = 5*[randn(500,1)-5, randn(500,1)+5];
d = 5*[randn(500,1)-5, randn(500,1)-5];
e = 5*[randn(500,1), randn(500,1)];
X = [a;b;c;d;e];
N=size(X,1);
GT = zeros(N,1);
GT(1:500)=1;
GT(501:1000)=2;
GT(1001:1500)=3;
GT(1501:2000)=4;
GT(2001:2500)=5;

% randomize X first?
Y = [X GT];
newdata = Y(randperm(size(Y,1)),:)
X = newdata(:,1:2);
GT = newdata(:,3);

plot(a(:,1),a(:,2),'.');hold on;
plot(b(:,1),b(:,2),'r.'); 
plot(c(:,1),c(:,2),'g.'); 
plot(d(:,1),d(:,2),'k.');
plot(e(:,1),e(:,2),'c.');

% construct con_must and con_cannot 
n_constraints = 100;
done=0;
con_must = zeros(N,N);
con_cannot = zeros(N,N);
added_constraints=0;
while(~done)
	i = randi(N);
	j = randi(N);
	if (i==j)
		continue
	end
	if GT(i) == GT(j)
		con_must(i,j)=1;
		con_must(j,i)=1;
	end
	if GT(i) ~= GT(j)
		con_cannot(i,j)=1;
		con_cannot(j,i)=1;
	end
	added_constraints = added_constraints +1;
	if added_constraints  >= n_constraints
		done = 1; 
	end
end

% add constraints for face
X = load('face_feature.txt');
N = size(X,1);
con_cannot = zeros(N,N);
con_must=zeros(N,N);
face_cannot = load('face_cannot.txt');
n_constraints = length(face_cannot)
for k=1:n_constraints
	i = face_cannot(k,1)+1;
	j = face_cannot(k,2)+1;
	con_cannot(i,j)=1;
	con_cannot(j,i)=1;
end
face_GT = load('face_GT.txt');
GT = face_GT(:,2);
K=12;
iters=100;


%############################

% add constraints for location
X = load('location_feature.txt');
N = size(X,1);
con_cannot = zeros(N,N);
con_must=zeros(N,N);
location_must = load('location_must.txt');
n_constraints = length(location_must)
for k=1:n_constraints
	i = location_must(k,1)+1;
	j = location_must(k,2)+1;
	con_must(i,j)=1;
	con_must(j,i)=1;
end
location_GT = load('location_GT.txt');
GT = location_GT(:,2)
K=11;
iters=100;

%################## kmeans constrained ####################
tic
[A, M, E] = kmeans_constrained(K,X,con_must, con_cannot,iters);
toc

% compute rand index
a=0;
b=0;
for i=1:N
	for j=1:N
		if i==j
			continue;
		end
		if GT(i)==GT(j) && A(i)==A(j)
			a = a+1;
		end
		if GT(i)~=GT(j) && A(i) ~=A(j)
			b = b+1;
		end
	end
end
allpairs = N*(N-1);
randindex = (a+b)/allpairs

 