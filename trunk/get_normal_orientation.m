function [out,in] = get_normal_orientation(mesh)
% Given a mesh the function checks how many of the normals of the surface
% are pointing inwards and how many are pointing outwards; this is done
% using the assumption that the average of the vertices is INSIDE the model
% - in the meaning that if you shoot a ray from that average to the center
% of any face in the mesh that ray will hit the inner side of the face;
% depending on the model this could be anywhere between somewhat untrue up
% to completely untrue.

out = 0;
in = 0;
mesh_center = mean(mesh.vertices);

% iterate over all faces
for i=1:size(mesh.faces,1)
    face = mesh.faces(i,:);
    face_center = (mesh.vertices(face(1),:) + mesh.vertices(face(2),:) + mesh.vertices(face(3),:)) / 3;
    
    ray = face_center - mesh_center; % we assume the ray points outwards
    face_normal = face_normal_from_mesh(i, mesh);
    
    if dot(ray, face_normal) > 0
        % same direction - normal is pointing outwards
        out = out + 1;
    elseif dot(ray, face_normal) < 0
        % opposite direction - normal is pointing inwards
        in = in + 1;
    end
end