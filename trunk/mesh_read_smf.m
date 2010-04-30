%
% This function reads an smf file and returns a mesh structure
%
% function [M, status] = mesh_read_smf(filename)
%
% Input -
%   - filename: name of smf file to load
%
% Output -
%   - M: triangle mesh: M.vertices(i, :) represents the 3D coordinates
%   of vertex 'i', while M.faces(i, :) contains the indices of the three
%   vertices that compose face 'i'. If the mesh also has color
%   attributes, they are stored in M.FaceVertexCData and
%   M.FaceVertexAlphaData
%   - status: this variable is 0 if the file was succesfuly opened, or 1
%   otherwise
%
% See also mesh_read
%
function [M, status] = mesh_read_smf(filename)
%
% Copyright (c) 2008, 2009 Oliver van Kaick <ovankaic@cs.sfu.ca>
%

    % Open file
    fid = fopen(filename);
    status = 0;
    if fid == -1
        disp(['ERROR: could not open file "' filename '"']);
        M = [];
        status = 1;
        return;
    end

    % Read content
    vnum = 1;
    fnum = 1;
    cnum = 1;
    while(feof(fid) ~= 1)
        line = '';
        line = fgetl(fid);
        if length(line) == 0
            continue;
        end
        if line(1) == 'v'
            line = line(3:length(line));
            X(vnum, :) = sscanf(line, '%f %f %f');
            vnum = vnum + 1;
        elseif line(1) == 'f'
            line = line(3:length(line));
            F(fnum, :) = sscanf(line, '%d %d %d');
            fnum = fnum + 1;
        elseif line(1) == 'c'
            line = line(3:length(line));
            C(cnum, :) = sscanf(line, '%f %f %f %f');
            cnum = cnum + 1;
        end
    end

    %X1 = [inf inf inf];
    %for i = 1:vnum
    %    for j = 1:length(X1(:,1))
    %        if X(i,:) == X1(j,:)
    %            break;
    %        end
    %    end
    %    if j == length(X1(:,1));
    %        X1 = [X1;X(i,:)];
    %    end
    %end
    %X = X1(2:length(X1(:,1)),:);

    % Close file
    fclose(fid);

    % Set up output mesh
    M = struct();
    M.vertices = X;
    M.faces = F;
    if cnum > 1
        M.FaceVertexCData = C(:, 1:3);
        M.FaceVertexAlphaData = C(:, 4);
    end
