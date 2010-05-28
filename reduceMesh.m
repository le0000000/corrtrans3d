function [out] = reduceMesh(mesh, nNewVertices)

	if libisloaded('FastImplementations') == 0
		loadlibrary('FastImplementations\Release\FastImplementations.dll', 'FastImplementations\fast_implementations.h');
	end

	X = mesh.vertices;
	F = mesh.faces;
	
	[nNewFaces newX newF] = calllib('FastImplementations', 'reduceMesh', X', F', size(X, 1), size(F, 1), nNewVertices);
	
	out.vertices = newX(:, 1:nNewVertices)';
	out.faces = newF(:, 1:nNewFaces)';
		