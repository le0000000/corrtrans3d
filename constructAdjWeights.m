function [W] = constructAdjWeights(X, F)

	n = length(X);
	f = length(F);
	W = sparse(n, n);
	for i = 1:f
		W(F(i, 1), F(i, 2)) = 1;
		W(F(i, 2), F(i, 1)) = 1;
		W(F(i, 2), F(i, 3)) = 1;
		W(F(i, 3), F(i, 2)) = 1;
		W(F(i, 3), F(i, 1)) = 1;
		W(F(i, 1), F(i, 3)) = 1;
	end
	for i = 1:n
		ind = find(W(i,:));
		k = length(ind);
		W(i, ind) = ones(1, k) / k;
	end
