function [mesh] = mesh_read_mat(filename)

	model = load(filename);
	
	mesh.faces = model.surface.TRIV;
	mesh.vertices = [model.surface.X model.surface.Y model.surface.Z];

    % normalize the vertex coordinates from [-Inf, Inf] to [0,1]
    
    min_val = min(mesh.vertices(:));
    max_val = max(mesh.vertices(:));
    
    mesh.vertices = (mesh.vertices - min_val) ./ (max_val - min_val);