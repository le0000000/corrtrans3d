%
% This function selects feature points on a mesh using the MAX-MIN
% selection. These feature points can be used for subsampling with the
% Nystrom algorithm. They are also used to color the meshes.
%
% P = selectAnchors(A, num)
%
% Input:
%   - A: <n x n> matrix of pairwise geodesic distances between the 'n'
%   vertices of the mesh (computed with the function constructGeodesic)
%   - num: number of feature points required
%
% Output:
%   - P: <1 x num> row vector of the indices of the feature points
%
function P = selectAnchors(A, num)

    if num < 1
        return;
    end
    n = length(A(:,1));
    P = zeros(1, num);
    tmp = sum(A, 2);
    [junk P(1)] = max(tmp);
    %P(1) = floor(rand(1,1)*(n-1)) + 1;
    if num == 1
        return;
    end
    [junk P(2)] = max(A(P(1),:));
    for i = 1:num-2
        [junk P(i+2)] = max(sum(A(P(1:i+1),:)));
    end
