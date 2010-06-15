
function [mesh_out] = transformUsingSE(mesh_in)

	F = mesh_in.faces;
	X = mesh_in.vertices;

    %disp('Computing geodesic distances');

    % Compute approximate geodesic distances (using graph distances)
	A = computeGeodesicMetric(X, F);

	%disp('Computing spectral embedding');

    % Apply Gaussian to distance matrices
    G = applyGaussian(A);

    % Compute spectral decomposition of distance matrices
    [Vinit Dinit] = eig_s2(G, 'd', 4);

    % Scale eigenvectors by eigenvalues
    for i=1:4
        Vinit(:,i) = Vinit(:,i) * sqrt(abs(Dinit(i, i)));
    end

	Z = Vinit(:, 2:4);
	
	mesh_out.faces = F;
	mesh_out.vertices = Z;

	