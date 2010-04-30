%
% This function displays a triangle mesh
%
% function p = mesh_show(M [, show_edges])
%
% Input -
%   - M: triangle mesh: M.vertices(i, :) represents the 3D coordinates
%   of vertex 'i', while M.faces(i, :) contains the indices of the three
%   vertices that compose face 'i'
%   - show_edges (optional): if set to 1, triangle edges are shown in
%   black
%
% Output -
%   - p (optional): patch object for triangle mesh
%
function varargout = mesh_show(M, show_edges)
%
% Copyright (c) 2008 Oliver van Kaick <ovankaic@cs.sfu.ca>
%

% Check input arguments
if nargin <= 1
    show_edges = 0;
end

% create new window
figure
    
% Plot mesh
p = patch(M);
if nargout > 0
    varargout{1} = p;
end

% Set normals
%isonormals(X, Y, Z, V, p);

% Set edge colors
set(p,'FaceColor','red','EdgeColor','none');
if show_edges
    set(p,'FaceColor','red','EdgeColor','black');
end

% Set aspect ratio
daspect([1 1 1]);

% Set axis
%axis tight;
axis([-1.1 1.1 -1.1 1.1 -1.1 1.1]);

% Set lightning
camlight;
lighting gouraud;
light('Position',[1 0 0],'Style','infinite');
light('Position',[-1 0 0],'Style','infinite');
light('Position',[0 1 0],'Style','infinite');

% Set view
view(2); 
