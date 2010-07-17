function adj = build_vertex_adj(model)
% Given a model, calculates a sparse adjacency matrix for its vertices.
% The adjacency matrix is symmetrical.

n = size(model.vertices,1);

adj = sparse(n,n);

for i=1:size(model.faces,1)
    face = model.faces(i,:);
    
    adj(face(1), face(2)) = 1;
    adj(face(2), face(1)) = 1;
    adj(face(1), face(3)) = 1;
    adj(face(3), face(1)) = 1;
    adj(face(2), face(3)) = 1;
    adj(face(3), face(2)) = 1;
    
end