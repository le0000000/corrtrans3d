%
% This function calculates the matching between the vertices of two
% meshes using anchor points.
%
% [K S idx cost] = computeImprovedMatching(S, A1, A2, anc_num)
%
% Input :
%   If the two meshes contain 'n' and 'm' vertices, respectively.
%   - S: <n x m> dissimilarity matrix where S(i, j) is the cost of
%   matching the i-th vertex of mesh 1 with j-th vertex of mesh2
%   - A1: <n x n> pairwise geodesic matrix for mesh 1 (obtained from
%   constructGeodesic function)
%   - A2: similarly as A1 for mesh 2
%   - anc_num: number of anchor points
%
% Output:
%   - K: <n x 2> matching matrix where the vertex K(i, 1) of mesh 1
%   matches the vertex K(i, 2) of mesh 2
%   - S: new dissimilarity matrix which has the proximity cost added to
%   the S given in the input
%   - idx: <anc_num x 2> array of selected anchor point pairs
%   - cost: the cost of matching K
%
function [K S idx cost] = computeImprovedMatching(S, A1, A2, anc_num)

    n1 = size(S,1);
    n2 = size(S,2);
    S = S/max(max(abs(S)));
    idx = [];
    Sim(1).mat = S;
    for a = 1:anc_num
        min = inf;
        idx(a,:) = [0 0];
        for i = 1:n1
            for j = 1:n2
                if min > S(i,j)
                    min = S(i,j);
                    idx(a,:) = [i,j];
                end
            end
        end
        %[tmp tmp1] = min(S);
        %[junk idx(a,2)] = min(tmp);
        %idx(a,1) = tmp1(idx(a,2));
        S(idx(a,1), idx(a,2)) = inf;
        fvec1(a,:) = A1(idx(a,1),:);
        fvec2(a,:) = A2(idx(a,2),:);
        fvec1(a,:) = fvec1(a,:)/max(fvec1(a,:));
        fvec2(a,:) = fvec2(a,:)/max(fvec2(a,:));
        for i = 1:n1
            for j = 1:n2
                S(i,j) = S(i,j) - (fvec1(a,i)+fvec2(a,j))/2;
            end
        end
        for i = 1:n1
            for j = 1:n2
                Sim(a+1).mat(i,j) = ((fvec1(a,i) - fvec2(a,j))^2);
            end
        end
        Sim(a+1).mat = Sim(a+1).mat/max(max(Sim(a+1).mat));
    end
    
    S = Sim(1).mat;
    for a = 1:anc_num
        S = S + (1/1)*Sim(a+1).mat;
    end

    %K = find_matching_old(S);
    [K cost] = computeMatching(S);
    %[K cost] = greedy_matching(S);
    %[iz D] = bghungar(-S);
    %for i = 1:length(iz)
    %    K(i,1) = i;
    %    K(i,2) = iz(i);
    %end
