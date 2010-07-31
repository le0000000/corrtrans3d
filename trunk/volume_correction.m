function model = volume_correction(model, volumes, opposites, angles, depth, rounds)
% Applies volume correction on the given model using the following method:
% for each vertex a measure of volume is provided; also provided is an
% opposing vertex for each vertex in the model. The basic idea is that each
% vertex applies a certain amount of force on some of the other vectors;
% the sum of all forces applied to all vertices is applied to the vertices
% of the model; this is repeated for a given number of rounds. The vertices
% affected by each vertex's force are the neighbours (up to the specified
% depth) of the "opposite" vertex; the direction and magnitude are such
% that if vertex i has "volume" Vi and affects vertex j, we always want j
% to be exactly Vi away from i, so assuming it isn't we move j to be
% half-way to be exactly Vi away from i.

% this is applied to the force we calculate
force_const = 0.3;

% normalize initial model
model = normalizeMesh01(model);

n = size(model.vertices,1);

disp('Calculating vertex adjacency matrix');
vertex_adj = build_vertex_adj(model);

disp('Applying force iteratively');
for r=1:rounds
    forces = zeros(n,3);
    % applicants(i) is the number of vertices applying force to i
    applicants = zeros(n,1);
    
    %disp('Calculating distances');
    distances = zeros(n);
    for i=1:n
        for j=1:n
            distances(i,j) = norm(model.vertices(i,:) - model.vertices(j,:));
            distances(j,i) = distances(i,j);
        end
    end
    
    for i=1:n
        if 0 == opposites(i) || 0 == volumes(i)
            % some vertices don't apply any force
            continue;
        end
        
        neighbours = get_neighbours(vertex_adj, depth, opposites(i));
        % apply force to each of the neighbours
        for neighbour_idx = neighbours
            
            % NaNs started to appear - I guess because i_to_neighbour_idx
            % has norm 0 because i == i_to_neighbour_idx (no vertex is its
            % own opposite, but a vertex could be a 3rd degree neighbour of
            % its opposite)
            if i == neighbour_idx
                continue;
            end
            

            should_be = model.vertices(i,:) + (i_to_neighbour_idx ./ norm(i_to_neighbour_idx)) * volumes(i);
            
            forces(neighbour_idx,:) = forces(neighbour_idx,:) + ((should_be - model.vertices(neighbour_idx,:)) ./ 2);
            applicants(neighbour_idx) = applicants(neighbour_idx) + 1;
        end % opposing neighbours loop
    end % vertices loop
    
    % apply forces and normalize
    % but first normalize the force by number of applicants
    
    for i=1:n
        if (applicants(i) ~= 0) % some vertices don't apply force
            forces(i,:) = forces(i,:) ./ applicants(i);
        end
    end
    
    model.vertices = model.vertices + (forces .* force_const);
    model = normalizeMesh01(model);
    
    mesh_show(model);
    pause;
    
end % rounds loop








