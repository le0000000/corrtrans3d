%
% This function computes a dissimilarity matrix from a list of
% d-dimensional points, using the Euclidean distance between the points
%
% A = computePairwise(X)
%
% Input:
%   - X: <n x d> matrix of d-dimensional points
%
% Output:
%   - A: <n x n> matrix of pairwise Euclidean distances between every
%   two points in X
%
function A = computePairwise(X)

    n = length(X(:,1));
    
    for i = 1:n
        A(i,i) = 0;
        for j = i+1:n
            A(i,j) = sqrt(sum((X(i,:) - X(j,:)).^2));
            A(j,i) = A(i,j);
        end
    end
