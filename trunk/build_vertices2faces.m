function vertices2faces = build_vertices2faces(model)
% Given a model, returns a n x m sparse matrix, where n is the number of
% vertices in the model and m is the number of faces; the matrix contains 1
% in cell (i,j) iff vertex i is part of face j.

n = size(model.vertices, 1);
m = size(model.faces, 1);

vertices2faces = sparse(n,m);

for i=1:m
    face = model.faces(i,:);
    vertices2faces(face(1), i) = 1;
    vertices2faces(face(2), i) = 1;
    vertices2faces(face(3), i) = 1;
end

