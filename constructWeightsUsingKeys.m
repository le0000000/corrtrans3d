function [W] = constructWeightsUsingKeys(X, F, depth, nKeyVertices)

	[n dim] = size(X);
	f = size(F, 1);
	keyVertices = findKeyVertices(X, F, nKeyVertices);

	%-----usual 0-1 adjacency matrix
	adj = zeros(n, n);  
	for i = 1:f
		adj(F(i, 1), F(i, 2)) = 1;
		adj(F(i, 2), F(i, 1)) = 1;
		adj(F(i, 2), F(i, 3)) = 1;
		adj(F(i, 3), F(i, 2)) = 1;
		adj(F(i, 3), F(i, 1)) = 1;
		adj(F(i, 1), F(i, 3)) = 1;
	end

	for i = 1:n
		
		% find all neighbors up to specified depth
		neighbors = [i];
		for d = 1:depth
			for v = neighbors
				neighbors = union(neighbors, find(adj(v, :)));
			end
		end

		if length(find(keyVertices == i)) == 0 % i is not a key vertex
			neighbors = setdiff(neighbors, [i]);
			W(i, neighbors) = calculateWeights(X(neighbors, :), X(i, :));
		else % i is a key vertex
			[neighborsX, neighborsF] = submesh(X, F, neighbors); % mesh of current vertex's neighbors
			neighborsI = find(neighbors == i); % new index of the current vertex
			
			neighborsMesh.vertices = neighborsX;
			neighborsMesh.faces = neighborsF;
			
			flattedNeighborsMesh = transformUsingSE(neighborsMesh);
			
			% get coordinates of all vertices except of current one
			flattedX = flattedNeighborsMesh.vertices(setdiff(1:length(neighbors), [neighborsI]), :);
			% get coordinates of current vertex
			flattedI = flattedNeighborsMesh.vertices(neighborsI, :);
			
			W(i, setdiff(neighbors, [i])) = calculateWeights(flattedX, flattedI);	
		end

	end

function [w] = calculateWeights(X, p)
% finds weights such that:
%	p == w' * X
% and:
%	sum(w) == 1
%

	% construct linear system for determining the weights:
	% x1 x2 x3 ... xn  |  x'
	% y1 y2 y3 ... yn  |  y'
	% z1 z2 z3 ... zn  |  z'
	% 1  1  1  ... 1   |  1
	A = [X'; ones(1, size(X, 1))];
	b = [p'; 1];
	
	% minimal solution is better because it will guarantee that weights will be
	% distributed more equally between the neighbors
	% (Regular x = A \ b, will generally assign 0 to most weights)
	w = minimalSolution(A, b);
	
%
% This function returns solution with minimal L2 norm for Ax = b system.
%
% Algorithm: obtain arbitrary solution vector and make it orthogonal to kernel of A
%
function [x] = minimalSolution(A, b)
	
	sol = A \ b;
	kernel = null(A);
	x = sol - sum(kernel * diag(sol' * kernel), 2);
