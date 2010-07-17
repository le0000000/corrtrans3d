function neighbours = get_neighbours(vertex_adj, depth, index)
% Returns all neighbours of the vertex with the specified index, up to the
% specified depth.

neighbours = [index];

for d = 1:depth
   for v = neighbours
       neighbours = union(neighbours, find(vertex_adj(v, :)));
   end
end