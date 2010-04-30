%
% This function exhaustively reorders the eigenvectors of a spectral
% embedding to best match the eigenvectors of another embedding.
%
% E2 = exhaustiveReorder(E1, E2, k, F1, F2, A1, A2)
%
% Input:
%   - E1, E2: <n x *> and <m x *> matrices defining the spectral
%   embedding of meshes 1 and 2, respectively
%   - k: actual dimension to be used for the embedding. For example E1
%   and E2 could have as many as n and m columns, but only the first k
%   columns will be considered
%   - F1, F2: <n x 3> and <m x 3> face lists. F1(i, :) denotes the three
%   vertices of face 'i' for mesh 1.
%   - A1, A2: <n x n> and <m x m> matrices, where A1(i, j) is the graph
%   distance between vertex 'i' and vertex 'j' on mesh 1
%
% Output:
%   - E2: a <m x *> matrix defining the embedding, where the first k
%   columns are aligned with E1's first k columns
%
function E2 = exhaustiveReorder(E1, E2, k, F1, F2, A1, A2)

    n1 = length(E1(:,1));
    n2 = length(E2(:,1));
    
    perm = perms(2:k);
    for i = 0:2^(k-1)-1
        comb(i+1,:) = str2num(dec2bin(i,k-1)')';
    end

    mincost = inf;
    for p = 1:length(perm(:,1));
        for c = 1:length(comb(:,1));
            tempE2 = E2;
            tempE2(:,2:k) = E2(:,perm(p,:));
            todisp = perm(p,:);
            for i = 2:k;
                if comb(c,i-1) == 1;
                    tempE2(:,i) = -tempE2(:,i);
                    todisp(i-1) = -todisp(i-1);
                end;
            end;

            Z = zeros(n1,n2);
            for i=2:k;
              tmp = E1(:,i) * ones(1,n2) - ones(n1,1) * tempE2(:,i)';
              %tmp1 = abs(E1(:,i)) * ones(1,n2) + ones(n1,1) * abs(tempE2(:,i))';
              tmp = (tmp .* tmp);%./tmp1;
              Z = Z + tmp;
            end;
            Z = sqrt(Z);
            [K cost] = computeMatching(Z);
            %disp([todisp cost]);
            %[K junk junk cost] = computeImprovedMatching(Z, A1, A2, 5);
            %[K cost] = greedy_matching(Z);
            if cost < mincost;
                mincost = cost;
                minperm = todisp;
                minE2 = tempE2;
            end;
        end;
    end;
    %disp(minperm);
    E2 = minE2;
