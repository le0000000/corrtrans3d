function [newX, newF] = submesh(X, F, vs)
% Build sub-mesh of the mesh given by (X,F) using vertices specified by 'vs'.

	% new set of vertices
	newX = X(vs, :);
	
	% mapping of old vertex indices to new indices
	vertexMapping = zeros(length(vs), 1);
	vertexMapping(vs) = 1:length(vs);
	
	% find faces that lie on the new vertices only (i.e. 3 vertices of the face are in 'vs')
	idxs1 = [];
	idxs2 = [];
	idxs3 = [];
	for u = vs
		idxs1 = union(idxs1, find(F(:,1) == u));
		idxs2 = union(idxs2, find(F(:,2) == u));
		idxs3 = union(idxs3, find(F(:,3) == u));
	end
	idxs = intersect(idxs1, idxs2);
	idxs = intersect(idxs, idxs3);
	
	% get the faces and transform vertex indices using the above mapping
	newF = vertexMapping(F(idxs, :));
