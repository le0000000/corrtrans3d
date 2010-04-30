%
% This function displays a triangle mesh using the color attribute
%
% function p = mesh_show_color(M [, F])
%
% Input -
%   - M: triangle mesh: M.vertices(i, :) represents the 3D coordinates
%   of vertex 'i', while M.faces(i, :) contains the indices of the three
%   vertices that compose face 'i'. If 'FaceVertexCData' is defined, it
%   is used as the color attributes of the mesh
%   - F (optional): if this parameter is provided, it is used as the
%   'FaceVertexCData' of the mesh
%
% Output -
%   - p (optional): patch object for triangle mesh
%
function varargout = mesh_show_color(M, F)
%
% Copyright (c) 2008 Oliver van Kaick <ovankaic@cs.sfu.ca>
%

% Check if external FaceVertexCData was provided
if nargin > 1
    M.FaceVertexCData = F;
end

% Plot mesh
p = patch(M);
if nargout > 0
    varargout{1} = p;
end

% Set normals
%isonormals(X, Y, Z, V, p);

% Set edge colors
if (isfield(M, 'FaceVertexCData'))
    if size(M.FaceVertexCData, 1) == size(M.faces, 1)
        % Face interpolation can only be flat
        set(p,'FaceColor','flat','EdgeColor','none');
    else
        % Vertex colors should be interpolated across the faces
        set(p,'FaceColor','interp','EdgeColor','none');
    end
else
    set(p,'FaceColor','red','EdgeColor','none');
end
%set(p,'FaceColor','red','EdgeColor','black');

% Set aspect ratio
daspect([1 1 1]);

% Set axis
%axis tight;
axis([-1.1 1.1 -1.1 1.1 -1.1 1.1]);

% Set lightning
camlight;
lighting gouraud;
%lighting phong;
light('Position',[1 0 0],'Style','infinite');
light('Position',[-1 0 0],'Style','infinite');
light('Position',[0 1 0],'Style','infinite');

% Set view
view(2); 
