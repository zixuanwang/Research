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

iters=100;
allpairs = N*(N-1);
randindex = zeros(20,1);
for K=2:20;
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
	randindex(K,1) = (a+b)/allpairs;
end
dlmwrite('face_withconstraint_K1to20.dat', randindex, 'delimiter', '\t');

%################
iters=100;
allpairs = N*(N-1);
randindex = zeros(20,1);
con_cannot = zeros(N,N);
con_must=zeros(N,N);
for K=2:20;
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
	randindex(K,1) = (a+b)/allpairs;
end
dlmwrite('face_withoutconstraint_K1to20.dat', randindex, 'delimiter', '\t');


%####################
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
iters=100;
allpairs = N*(N-1);
for K=2:20;
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
	randindex(K,1) = (a+b)/allpairs;
end
dlmwrite('location_withconstraint_K1to20.dat', randindex, 'delimiter', '\t');


%###########
X = load('location_feature.txt');
N = size(X,1);
con_cannot = zeros(N,N);
con_must=zeros(N,N);
location_GT = load('location_GT.txt');
GT = location_GT(:,2)
iters=100;
allpairs = N*(N-1);
for K=2:20;
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
	randindex(K,1) = (a+b)/allpairs;
end
dlmwrite('location_withoutconstraint_K1to20.dat', randindex, 'delimiter', '\t');