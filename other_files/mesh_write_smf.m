%
% This function writes a mesh structure to an smf file
%
% function mesh_write_smf(M, filename);
%
% Input -
%   - M: triangle mesh: M.vertices(i, :) represents the 3D coordinates
%   of vertex 'i', while M.faces(i, :) contains the indices of the three
%   vertices that compose face 'i'. If the mesh also has color
%   attributes defined in M.FaceVertexCData and M.FaceVertexAlphaData,
%   they are written to the file as entries of the form 'c <r> <g> <b>
%   <alpha>'
%   - filename: name of smf file to create
%
% Output -
%   - status: this variable is 0 if the file was succesfuly written, or
%   1 otherwise
%
% See also mesh_write
%
function status = mesh_write_smf(M, filename);
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

% Write vertices
for i = 1:size(M.vertices, 1)
    fprintf(fid, 'v %f %f %f\n', ...
                M.vertices(i, 1), M.vertices(i, 2), M.vertices(i, 3));
end

% Write faces
for i = 1:size(M.faces, 1)
    fprintf(fid, 'f %d %d %d\n', ...
                M.faces(i, 1), M.faces(i, 2), M.faces(i, 3));
end

% Write colors, if defined
if (isfield(M, 'FaceVertexCData'))
    % Check if colors are defined as RGB or a function
    if size(M.FaceVertexCData, 2) == 1
        % Map function values to RGB data
        % Map function values from [min, max] to [0, 2/3], which is red
        % to blue hue in an HSV color map
        func = mesh_map_val(M.FaceVertexCData, 0, 2/3);
        % Use max(func)-func as the hue value and get RGB colors
        % Saturation and brightness are set to 0.8
        clr = hsv2rgb([max(func)-func ones(length(func), 1)*0.8 ...
                            ones(length(func),1)*0.8]);
    else
        % If we have RGB data, just use it
        clr = M.FaceVertexCData;
    end
    % Print colors
    if size(clr, 1) == size(M.vertices, 1)
        fprintf(fid, 'bind c vertex\n');
        if (isfield(M, 'FaceVertexAlphaData'))
            for i = 1:size(M.FaceVertexCData, 1)
                fprintf(fid, 'c %f %f %f %f\n', ...
                        clr(i, 1), clr(i, 2), clr(i, 3), ...
                        M.FaceVertexAlphaData(i));
            end
        else
            for i = 1:size(M.FaceVertexCData, 1)
                fprintf(fid, 'c %f %f %f 1\n', ...
                        clr(i, 1), clr(i, 2), clr(i, 3));
            end
        end
    else
        fprintf(fid, 'bind c face\n');
        if (isfield(M, 'FaceVertexAlphaData'))
            for i = 1:size(M.FaceVertexCData, 1)
                fprintf(fid, 'c %f %f %f %f\n', ...
                        clr(i, 1), clr(i, 2), clr(i, 3), ...
                        M.FaceVertexAlphaData(i));
            end
        else
            for i = 1:size(M.FaceVertexCData, 1)
                fprintf(fid, 'c %f %f %f 1\n', ...
                        clr(i, 1), clr(i, 2), clr(i, 3));
            end
        end
    end
end

% Close file
fclose(fid);
