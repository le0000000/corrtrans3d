% Use factor of 40-50 for the example meshes
function [mesh_out] = transformUsingSENystrom(mesh_in, nystrom_factor)

	F = mesh_in.faces;
	X = mesh_in.vertices;

    disp('Computing geodesic distances');

	% actually there is no need to compute distances between all pairs.
	% need to improve this
	A = computeGeodesicMetric(X, F);

	disp('Computing spectral embedding');
	
    % Apply Gaussian to distance matrices
    G = applyGaussian(A);
	
	[Vinit Dinit] = fast_svd(G, 3, nystrom_factor);
	
	Z = Vinit(:, 1:3);

	mesh_out.faces = F;
	mesh_out.vertices = Z;
	
	% returned mesh is scaled (need to understand why),
	% meanwhile just normalize it in order to display properly
	mesh_out = normalizeMesh(mesh_out);
