function mesh = normalizeMesh01(mesh)
% Normalizes the mesh vertices' coordinates to [0,1].

u = max(mesh.vertices(:));
l = min(mesh.vertices(:));

mesh.vertices = (mesh.vertices - l) ./ (u - l);