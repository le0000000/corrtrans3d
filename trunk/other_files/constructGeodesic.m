%
% This function computes the graph distance between vertices of a
% triangle mesh.
%
% G = constructGeodesic(F, X) 
%
% Input:
%   The input mesh is given by F and X.
%   - F: <m x 3> face list. F(i, :) denotes the three vertices of face
%   'i', indexed in X
%   - X: <n x 3> vertex list. X(i, :) denotes the three coordinates of
%   vertex 'i'
%
% Output:
%   - G: <n x n> matrix, where G(i,j) is the approximate geodesic
%   distance (graph distance) between vertex 'i' and vertex 'j' on the
%   mesh
%
function G = constructGeodesic(F, X)

    [n dim] = size(X);
    f = length(F(:, 1));
    
    adj = zeros(n, n);  %-----unsual 0-1 adjacency matrix
    for i = 1:f
        adj(F(i, 1), F(i, 2)) = 1;
        adj(F(i, 2), F(i, 1)) = 1;
        adj(F(i, 2), F(i, 3)) = 1;
        adj(F(i, 3), F(i, 2)) = 1;
        adj(F(i, 3), F(i, 1)) = 1;
        adj(F(i, 1), F(i, 3)) = 1;
    end

    A = zeros(n,n);
    for i=1:dim
      tmp = X(:,i) * ones(1,n) - ones(n,1) * X(:,i)';
      tmp = tmp.* tmp;
      A = A + tmp;
    end
    A = (A + A')/2;
    A = sqrt(A).*adj;
    for i =1:n
        A(i,i) = -2;
    end
    A(find(A == 0)) = inf;
    A(find(A == -2)) = 0;
    %A = zeros(n, n);    %-----Adjacency matrix according to Frank's specification
    %for i = 1:n
    %    A(i, i) = 0;
    %    for j = i+1:n
    %        if(adj(i, j) == 1)
    %            A(i, j) = sqrt(sum((X(i, :) - X(j, :)).^2)); %-----Geodesic distance is same as euclidean distance
    %        else
    %            A(i, j) = inf;
    %        end
    %        A(j, i) = A(i, j);
    %    end
    %end
    
    G = pw_graph_dist(A);    %-----Call Frank's Dijkstra's implementation

    %for i = 1:n %-----Make it symmetric (numerical errors)
    %    for j = i+1:n
    %        %G(i,j) = sqrt(sum((X(i, :) - X(j, :)).^2));
    %        G(j, i) = G(i, j);
    %    end
    %end
    G = (G + G')/2;
