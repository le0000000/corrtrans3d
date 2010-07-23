function exc_num = verify_consistency_of_normal_dir(mesh)
% Verifies the consistency of the directions of normals of mesh faces of a
% given mesh; this is done by counting the number of pairs of neighbour
% faces that have significantly different normals (their dot product is
% negative).

% this is the number of exceptions to the assumption that the normals of
% faces change gradually in a mesh (positive dot product).
exc_num = 0;

% calculate adjacency matrix of faces
adj = build_face_neighbourhood(mesh);

% iterate over every face in the mesh
for i=1:size(mesh.faces,1)
    % find indices of all faces neighbouring this face
    neighbours = find(adj(i,:)); % returns indices of all neighbours
    % calculate the normal of the central face
    reference_normal = face_normal_from_mesh(i,mesh);
     
%     disp('--------------------------------------');
%     disp(i);
%     disp(neighbours);
%     disp(reference_normal);
    
    % for each neighbour calculate its normal and compare the dot product
    for j=1:size(neighbours)
       neighbour_normal = face_normal_from_mesh(neighbours(j), mesh);
       %disp(neighbour_normal);
       if dot(reference_normal, neighbour_normal) < 0
           exc_num = exc_num + 1;
       end %if
    end % for neighbours loop
end % for face loop

exc_num = exc_num / 2;


