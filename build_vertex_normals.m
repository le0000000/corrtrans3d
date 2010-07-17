function normals = build_vertex_normals(model)
% Returns an nx3 array of normalized normals for the vertices of a given model.

n = size(model.vertices,1);
normals = zeros(n,3);

% build a list of which faces use which vector
v2f = build_vertices2faces(model);

% for each vertex calculate the sum of normals of all the faces that use
% that vertex (and normalize)

for i=1:n
   faces_idx = find(v2f(i,:));
   for j=1:size(faces_idx,2)
       normals(i,:) = normals(i,:) + face_normal_from_mesh(faces_idx(j), model);
   end
   normals(i,:) = normals(i,:) ./ norm(normals(i,:));
end