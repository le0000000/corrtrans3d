function adj = build_face_neighbourhood(mesh)
% Given a mesh, builds an adjacency matrix for its faces.
% For now, we'll implement this in O(n^2)  for simplicity.
% We do this by building a nxnx2 array of vertex indices; each couple of
% indices possibly defines an edge that defines an adjacency between two
% faces; if edge (i,j) exists we store in (i,j,1) the indices of the faces
% between it; otherwise we store (0,0).
% We treat edges symmterically - for (i,j) we add also (j,i).
% Once we have that, we traverse the matrix and build an adjacency matrix.


num_vertices = size(mesh.vertices,1);
% if for vertices i,j edges(i,j,:) are (0,0) - there is no edge between
% i and j; otherwise the entries are the indices of two faces that share
% the edge (i,j)
edges = zeros(num_vertices,num_vertices,2);

% traverse all faces
for i=1:size(mesh.faces,1)
    % for each face (p,r,s) for the six (symmetric) edges add the current
    % face to the edges matrix
    face = mesh.faces(i,:);
    % write all the edges into a easy-to-use matrix
    face_edges(1,:) = [face(1) face(2)];
    face_edges(2,:) = [face(2) face(1)];
    face_edges(3,:) = [face(1) face(3)];
    face_edges(4,:) = [face(3) face(1)];
    face_edges(5,:) = [face(2) face(3)];
    face_edges(6,:) = [face(3) face(2)];
    
    % for each edge check if there's allready an entry - if there is, add
    % the current face as the second entry
    for j=1:size(face_edges,1)
        if edges(face_edges(j,1), face_edges(j,2), 1) == 0
            % add first entry
            edges(face_edges(j,1), face_edges(j,2), 1) = i;
        else 
            % add second entry
            edges(face_edges(j,1), face_edges(j,2), 2) = i;
        end % if
    end % internal for loop
end % external for loop

% now that we know which edges connect between which faces we build an
% adjacency matrix for the faces
adj = sparse(size(mesh.faces,1));

% traverse all entries of edges and if the edge entry isn't zero mark the
% corresponding faces as neighbours

[neighbours_r, neighbours_c] = find(edges(:,:,1) > 0); % all interesting edges

for i=1:size(neighbours_r)
    % mark faces as neighbours
    faces = edges(neighbours_r(i), neighbours_c(i),:);
    %disp(faces);
    % in case of a hole the edge doesn't have a neighbouring face
    if 0 == faces(2)
        continue
    end % if hole
    
    adj(faces(1), faces(2)) = 1;
    adj(faces(2), faces(1)) = 1;
end



% whew... that's it