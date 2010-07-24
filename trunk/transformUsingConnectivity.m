function [mesh_out] = transformUsingConnectivity(mesh_in)

	F = mesh_in.faces;
	X = mesh_in.vertices;
	
	n = size(X, 1);

	disp('Computing weights');
	
	W = constructAdjWeights(X, F);
	
	disp('Computing SVD');
	
	% we should use something more effecient, since we need only 4 lowest values
	opt_struct = struct('disp', 0);
	[V D] = eigs(W, 4, 1.0, opt_struct);
	%[U L T] = svd(W - eye(n));
	
	% note that smallest singular value is 0, and corresponding singular vector is [1 1 1 ... 1]
	% this is because all solutions are invariant to translation
	mesh_out.vertices = real(V(:, 2:4));
	%mesh_out.vertices = T(:, n-3:n-1);
	mesh_out.faces = F;

	% scale the mesh for better view
	mesh_out = normalizeMesh(mesh_out);
