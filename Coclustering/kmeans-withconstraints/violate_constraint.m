function yes = violate_constraint(pointi, clusteri, A, con_must,con_cannot)
	must_idx = find(con_must(pointi,:));
	yes = 1;
	if( sum(A(must_idx) - clusteri) >0)
		yes=0;
	end

	cannot_idx =find(con_cannot(pointi,:));
	% if a cannot point is in the same cluster, fail
	if (nnz(A(cannot_idx) == clusteri)>0 )
		yes=0
	end
end