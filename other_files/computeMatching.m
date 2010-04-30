%
% This function calculates the matching between the vertices of two
% meshes from the dissimilarity cost matrix.
%
% [K cost] = computeMatching(S)
%
% Input:
%   - S: <n x m> matrix of dissimilarity
%
% Output:
%   - K: the matching
%   - cost: the matching cost.
%
% See the help of the function computeImprovedMatching for detailed help
% on the parameters S, K and cost.
%
function [K cost] = computeMatching(S)

    n = size(S,1);
    [Y I] = min(S, [], 2);
    K = [(1:n)' I];
    cost = sum(Y);
