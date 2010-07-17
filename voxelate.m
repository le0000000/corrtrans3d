function [volumes, opposites] = voxelate(model, depth)
% This function calculates a measure of volume for each vertex in the given
% model. The 'depth' specifies the amount of neighbours of the "opposing"
% vector that participate in the calculation of the average distance.
% NOTE that the mesh vertices' coordinates must be normalized to [0, 1]
% (!).
% 
% The return values are:
%  * volumes - a volume approximation for each vertex
%  * opposites - each vertex is matched with a vertex on the opposite side
%  of the current part of the mesh - the part that's supposed to be
%  directly affected by the volume correction

n = size(model.vertices,1);
volumes = zeros(n,1);
opposites = zeros(n,1);

disp('Calculating vertex normals');
normals = build_vertex_normals(model);

disp('Calculating distances');
distances = zeros(n);
for i=1:n
    for j=1:n
        distances(i,j) = norm(model.vertices(i,:) - model.vertices(j,:));
        distances(j,i) = distances(i,j);
    end
end

disp('Calculating vertex adjacency matrix');
vertex_adj = build_vertex_adj(model);

narrow = 0;

disp('Approximating volume');
for i=1:n
   % Find the "opposite" vertex for each vertex:
   % This is done in the following manner: the opposite vertex j of vertex
   % i is such that the dot product between i's normal and (j-i)
   % (normalized) is as close to 1 as possible, and j is closest to i;
   % that first we weed out all vertices with dot product lower than some
   % constant (say, 0.5) to make sure the opposite vertex is indeed on the
   % opposite side of the mesh, and then search for the highest value of
   % the product of (1 - distance) and the dot product described above.
   % Note that this requires the mesh vertices' coordinates to be
   % normalized.
   
   % calculate the dot product between the normal of i and (j - i)
   candidates = zeros(n,1);
   for j=1:n
       
       if i == j
           candidates(j) = 0;
           continue;
       end
       
       j_minus_i = model.vertices(j,:) - model.vertices(i,:);
       candidates(j) = dot(normals(i,:), j_minus_i ./ norm(j_minus_i));
   end
   
   % weed out all candidates with results lower than some constant
   candidates = candidates .* (candidates > 0.7);
   
   if 0 == sum(candidates)
       % it's possible that a vertex doesn't have a good candidate
       opposites(i) = 0; % illegal index
       volumes(i) = 0; % no force to apply
       continue; % skip
   end
   
   
   % memberwise multiplication with (1 - distances from i)
   candidates = candidates .* (1 - distances(i,:))';
   
   [max_val, max_val_idx] = max(candidates(:));
   
   opposites(i) = max_val_idx;
   
   % find all neighbours of the "opposite" vertex
   neighbours = get_neighbours(vertex_adj, depth, max_val_idx);
   
   % calculate the average distance between vertex i and all the
   % opposing vertices
   
   n_neighbours = size(neighbours, 2);
   
   for k=1:n_neighbours
        volumes(i) = volumes(i) + norm(model.vertices(i,:) - model.vertices(neighbours(k),:));
   end
   
   volumes(i) = volumes(i) ./ n_neighbours;
  
   
end % vertices loop
