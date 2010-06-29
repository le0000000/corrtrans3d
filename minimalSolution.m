%
% This function returns solution with minimal L2 norm for Ax = b system.
%
% Algorithm: obtain arbitrary solution vector and make it orthogonal to kernel of A
%
function [x] = minimalSolution(A, b)
	
	sol = A \ b;
	kernel = null(A);
	x = sol - sum(kernel * diag(sol' * kernel), 2);
