function reduced = PCA_reduce(ndim,X)
    c= mean(X);
    X_centered = X - repmat(c,size(X,1),1);
    opt.disp=0;
    covar = cov(X_centered);
    [p,D] = eigs(covar,ndim,'LA',opt);
    reduced = X*p;
end