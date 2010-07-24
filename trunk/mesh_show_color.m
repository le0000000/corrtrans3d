 function varargout = mesh_show_color(M, C)
 
	set(figure, 'renderer', 'zbuffer');
	F = M.faces;
	X = M.vertices;
	if nargin <= 1
		C = ones(length(X), 1) * [1 0 0];
	end
	
	%set(trisurf(F, X(:,1), X(:,2), X(:,3)), 'FaceColor', 'interp', 'FaceVertexCData', C, 'EdgeColor', 'none', 'BackFaceLighting', 'unlit');
	set(trisurf(F, X(:,1), X(:,2), X(:,3)), 'FaceColor', 'interp', 'FaceVertexCData', C, 'EdgeColor', 'none');
	%set(trisurf(F, X(:,1), X(:,2), X(:,3)), 'FaceColor', 'red', 'FaceLighting', 'gouraud', 'LineStyle', '-');
	%lighting gouraud;
	axis equal;
	hold on;
	%light('Position',[1 1 1],'Style','infinite');
	%light('Position',[-1 -1 -1],'Style','infinite');
	%material dull;
	