function normal = face_normal_from_mesh(face_ind, mesh)
% Given the mesh and an index of a face in it, calculates the normal of
% that face.
% ARGUMENTS:
% face_ind - an index of a face in the mesh
% mesh - the mesh within which to calculate the mesh

% get the indices of the vertices in the face
vertices_ind = mesh.faces(face_ind,:);

% translate each vertex index into a 1x3 row of coordinates
% give the entire triplet as argument to face_normal

vertices = zeros(3);

for i=1:3
    vertices(i,:) = mesh.vertices(vertices_ind(i),:);
end

normal = face_normal(vertices);


function normal = face_normal(face)
% Given an ordered triplet (p1,p2,p3)of points calculates the face normal,
% which is the cross product of (p3 - p1) x (p2 - p1); if the points are
% in clockwise order, the normal points "outside".
% ARGUMENTS:
% face - a 3x3 vector with rows representing points.

normal = cross(face(3,:) - face(1,:), face(2,:) - face(1,:));
normal = normal ./ norm(normal); % don't forget to normalize