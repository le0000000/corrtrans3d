%
% This function writes a mesh structure to an off file
%
% function mesh_write_off(M, filename);
%
% Input -
%   - M: triangle mesh: M.vertices(i, :) represents the 3D coordinates
%   of vertex 'i', while M.faces(i, :) contains the indices of the three
%   vertices that compose face 'i'
%   - filename: name of off file to create
%
% Output -
%   - status: this variable is 0 if the file was succesfuly opened, or 1
%   otherwise
%
% See also mesh_write
%
function status = mesh_write_off(M, filename);
%
% Copyright (c) 2008, 2009 Oliver van Kaick <ovankaic@cs.sfu.ca>
%

% Open file
fid = fopen(filename, 'w');
status = 0;
if fid == -1
    disp(['ERROR: could not open file "' filename '"']);
    status = 1;
    return;
end

% Write header
fprintf(fid, 'OFF\n');
fprintf(fid, '%d %d 0\n', size(M.vertices, 1), size(M.faces, 1));

% Write vertices
for i = 1:size(M.vertices, 1)
    fprintf(fid, '%f %f %f\n', ...
                M.vertices(i, 1), M.vertices(i, 2), M.vertices(i, 3));
end

% Write faces
for i = 1:size(M.faces, 1)
    fprintf(fid, '3 %d %d %d\n', ...
                M.faces(i, 1)-1, M.faces(i, 2)-1, M.faces(i, 3)-1);
end

% Close file
fclose(fid);
