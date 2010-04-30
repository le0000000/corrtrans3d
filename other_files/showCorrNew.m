%
% This function shows the correspondence between two meshes, using color
% coding.
%
% showCorrNew(F1, X1, F2, X2, A2, K)
%
% Input:
%   - F1, F2: <f1 x 3> and <f2 x 3> face lists. F1(i, :) denotes the three
%   vertices of face 'i' for mesh 1
%   - X1, X2: <n x 3> and <m x 3> vertex lists. X1(i, :) denotes the
%   three coordinates of vertex 'i' for mesh 1
%   - A2: <m x m> matrix, where A2(i, j) is the graph distance between
%   vertex 'i' and vertex 'j' on mesh 2
%   - K: <n x 2> correspondence matrix where the vertex K(i, 1) in mesh
%   1 corresponds to vertex K(i, 2) of mesh 2. Note that K(i, 1) should
%   be equal to i, for all i's
%
% Output:
%   - The correspondence is shown in a figure
%
function showCorrNew(F1, X1, F2, X2, A2, K)

    n1 = size(X1, 1);
    n2 = size(X2, 1);
    col = [0 0 1;
        0 1 0;
        0 1 1;
        1 0 0;
        1 0 1;
        1 1 0;
        %0.75 0.5 0.5;
        %0.75 0.25 0.25;
        %0.25 0.25 0.75;
        %0.25 0.75 0.25;
        %0.75 0.25 0.75;
        %0.25 0.75 0.75;
        %0.75 0.75 0.25;
        ];
    
    anum = length(col(:,1));
    P = selectAnchors(A2, anum);
    sig = max(max(A2))/anum;
    A2 = exp(-(A2.*A2)/(2*sig*sig));
    %A2 = 1 - A2/max(max(A2));    
    for i = 1:n2
        C2(i,:) = [0 0 0];
        for j = 1:anum
            C2(i,:) = C2(i,:) + A2(P(j),i)*col(j,:);
        end
        C2(i,:) = C2(i,:)/sum(A2(P,i));
    end

    for i = 1:n1
        C1(i,:) = [0 0 0];
    end
    for i = 1:length(K(:,1))
        if K(i,2) ~= 0
            C1(K(i,1),:) = C2(K(i,2),:);
        else
            C1(K(i,1),:) = [0 0 0];
        end
    end
    faceColoring = 'interp';
    faceLighting = 'phong';
    set(figure, 'renderer', 'zbuffer');
    %colormap(Cmap);
    set(trisurf(F1, X1(:,1), X1(:,2), X1(:,3)), 'FaceColor', faceColoring, 'FaceLighting', faceLighting, 'FaceVertexCData', C1, 'LineStyle', 'none');
    axis equal
    hold on;
    %figure;
    %colormap(Cmap);
    set(trisurf(F2, X2(:,1), X2(:,2), X2(:,3)), 'FaceColor', faceColoring, 'FaceLighting', faceLighting, 'FaceVertexCData', C2, 'LineStyle', 'none');
    light('Position',[1 0 0],'Style','infinite');
    material dull;
    axis equal
    axis off;
