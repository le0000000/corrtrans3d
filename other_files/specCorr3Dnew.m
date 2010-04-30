%
% Main function for "Robust 3D Shape Correspondence in the Spectral
% Domain". This function computes the correspondence between two meshes
% using the spectral method presented in SMI06.
%
% [K, Z, V1, V2] = specCorr3D(file1, file2, k)
%
% Input:
%   - file1: filename of input mesh 1
%   - file2: filename of input mesh 2
%   - k: number of eigenvectors used for the embedding
%
% Output:
%   - K: <n x 2> correspondence matrix, where vertex K(i, 1) of mesh 1
%   corresponds to vertex K(i, 2) of mesh 2, and 'n' is the number of
%   vertices of the smaller mesh
%   - Z: <n x m> similarity matrix, where Z(i, j) is the similarity
%   between vertex 'i' of mesh 1 and vertex 'j' of mesh 2
%   - V1, V2: coordinates for spectral embedding of meshes 1 and 2
%
% Copyright (c) 2006-2008 Richard (Hao) Zhang, Varun Jain, Oliver van
% Kaick
%
function [K, Z, V1, V2] = specCorr3D(file1, file2, k)

    disp('Computing spectral embedding');

    % Read input files
    X1 = load('~/meshes/nonrigid3d/michael1.vert');
    F1 = load('~/meshes/nonrigid3d/michael1.tri');
    X2 = load('~/meshes/nonrigid3d/michael2.vert');
    F2 = load('~/meshes/nonrigid3d/michael2.tri');

    % Compute approximate geodesic distances (using graph distances)
    A1 = constructGeodesic(F1, X1);
    A2 = constructGeodesic(F2, X2);

    % Get length of meshes
    n1 = length(A1(:, 1));
    n2 = length(A2(:, 1));

    % Apply Gaussian to distance matrices
    G1 = applyGaussian(A1);
    G2 = applyGaussian(A2);

    % Compute spectral decomposition of distance matrices
    [V1init D1init] = eig_s2(G1, 'd', k);
    [V2init D2init] = eig_s2(G2, 'd', k);

    % Scale eigenvectors by eigenvalues
    V1 = V1init; D1 = D1init;
    V2 = V2init; D2 = D2init;
    for i=1:k
        V1(:,i) = V1(:,i) * sqrt(abs(D1(i, i)));
        V2(:,i) = V2(:,i) * sqrt(abs(D2(i, i)));	    
    end

    % Apply sign correction to eigenvectors
    disp('Applying sign correction');
    V2(:,1:k) = signCorrection(V1(:,1:k), V2(:,1:k));
    %dispEigs(F1, X1, V1, F2, X2, V2, k);

    % Reoder eigenvectors
    disp('Reordering eigenvectors');
    tic;
    V2 = exhaustiveReorder(V1, V2, k, F1, F2, A1, A2);
    elapsed_time = toc;
    disp(sprintf('Time required for re-ordering: %f secs.', elapsed_time));

    % Compute Thin-Plate Spline matching
    disp('Computing TPS matching');
    [w d M V2(:,2:k)] = TPS(V1(:,2:k), V2(:,2:k), F1, F2);

    % Compose final similarity matrix
    Z = zeros(n1,n2);
    for i=2:k
      tmp = V1(:,i) * ones(1,n2) - ones(n1,1) * V2(:,i)';
      tmp = tmp .* tmp;
      Z = Z + tmp;
    end;
    Z = sqrt(Z);

    % Compute improved matching
    for anum = 0:5
        [K junk junk cost] = computeImprovedMatching(Z, A1, A2, anum);

        % Code to show the iterations of the matching computation
        % Change 'if 0' to 'if 1' to turn the code on
        if 0
            faceColoring = 'interp';
            faceLighting = 'phong';
            set(figure, 'renderer', 'zbuffer');
            set(trisurf(F1, X2(K(:,2),1), X2(K(:,2),2), X2(K(:,2),3)), 'FaceColor', faceColoring, 'FaceLighting', faceLighting, 'LineStyle', 'none');
            hold on;
            %set(trisurf(F2, X2(:,1)+0.1, X2(:,2), X2(:,3)), 'FaceColor', faceColoring, 'FaceLighting', faceLighting, 'LineStyle', 'none');
            %light('Position',[1 0 0],'Style','infinite');
            %material dull;
            axis equal
            axis off;    
        end
    end

    % Show correspondence (new code)
    showCorrNew(F1, X1, F2, X2, A2, K);

    % Show embeddings
    M1 = struct();
    M1.faces = F1;
    M1.vertices = V1(:, 1:3);
    mesh_show(M1);




%------------------------------------------------------------
% Compute sign correction for eigenvectors
function V = signCorrection(V1, V2)

    n1 = length(V1(:,1));
    n2 = length(V2(:,2));
    k = length(V1(1,:));

    for i = 1:k
        %disp(sprintf('\tCorrecting %d of %d.',i,m));
        for j = 1:n1
            for k = 1:n2
                Z(j,k) = norm(V1(j, 1:i)-V2(k, 1:i));
            end
        end
        [junk cost1] = computeMatching(Z);
        
        V2(:, i) = (-1) * V2(:, i);
        for j = 1:n1
            for k = 1:n2
                Z(j,k) = norm(V1(j, 1:i)-V2(k, 1:i));
            end
        end
        [junk cost2] = computeMatching(Z);
        
        if cost1 <= cost2
            V2(:, i) = (-1) * V2(:, i);
        end
    end
    V = V2;




%---------------------------------------------------
% Display eigenvectors
function dispEigs(F1, X1, E1, F2, X2, E2, k)
    %-----displaying stuff
    scrsz = get(0,'ScreenSize');
    fig = figure('Position',[1 scrsz(4) scrsz(3)-1 scrsz(4)], 'ToolBar', 'figure', 'Resize', 'on');
    
    faceColoring = 'interp';
    faceLighting = 'phong';
    mesh_num = 2;
    i = 1;
    for j = 1:k
        axes('Position', [(j-1)/k, 0.1+(i-1)*0.9/mesh_num, 1/k, 0.9/mesh_num]);
        set(trisurf(F1, X1(:,1), X1(:,2), X1(:,3), transferFunc(E1(:,j))), 'FaceColor', faceColoring, 'FaceLighting', faceLighting, 'LineStyle', 'none')
        hold on;
        set(gca, 'FontSize', 8);
        set(gca, 'XTickLabel', {''}, 'YTickLabel', {''}, 'ZTickLabel', {''});
        set(gca, 'Visible', 'off');
        %t = text(0,0,num2str(M(i).D(j,j)), 'Units', 'normalized');%title(num2str(M(i).D(j,j)));
        %t = text(0,0,num2str(N), 'Units', 'normalized');%title(num2str(M(i).D(j,j)));
        %set(t, 'Units', 'normalized', 'Extent', [0,0], 'Visible', 'on');
        axis equal;
    end
    i = 2;
    for j = 1:k
        axes('Position', [(j-1)/k, 0.1+(i-1)*0.9/mesh_num, 1/k, 0.9/mesh_num]);
        set(trisurf(F2, X2(:,1), X2(:,2), X2(:,3), transferFunc(E2(:,j))), 'FaceColor', faceColoring, 'FaceLighting', faceLighting, 'LineStyle', 'none')
        hold on;
        set(gca, 'FontSize', 8);
        set(gca, 'XTickLabel', {''}, 'YTickLabel', {''}, 'ZTickLabel', {''});
        set(gca, 'Visible', 'off');
        %t = text(0,0,num2str(M(i).D(j,j)), 'Units', 'normalized');%title(num2str(M(i).D(j,j)));
        %t = text(0,0,num2str(N), 'Units', 'normalized');%title(num2str(M(i).D(j,j)));
        %set(t, 'Units', 'normalized', 'Extent', [0,0], 'Visible', 'on');
        axis equal;
    end
