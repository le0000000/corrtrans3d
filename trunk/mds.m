function [X] = classicalMDS(A, d)
% X = classicalMDS(A, d)
% 
% A - affinity matrix (squared distances)
% d - number of dimensions for embedding
%
% X - coordinates of n points in d dimensions

	n = length(A);
	J = eye(n) - ones(n, n) / n;
	
	B = -0.5 * J * A * J;
	
	[X D] = eig_s2(B, 'd', d);
	
	