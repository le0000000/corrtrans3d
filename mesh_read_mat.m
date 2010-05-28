function [mesh] = mesh_read_mat(filename)

	model = load(filename);
	
	mesh.faces = model.surface.TRIV;
	mesh.vertices = [model.surface.X model.surface.Y model.surface.Z];
