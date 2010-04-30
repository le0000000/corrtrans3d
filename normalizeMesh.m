function [out_mesh] = normalizeMesh(m)

l = min(m.vertices);
u = max(m.vertices);

scale_factor = max(u - l) / 2;
m.vertices = m.vertices / scale_factor;

l = min(m.vertices);
u = max(m.vertices);
mid = (u + l) / 2;

m.vertices = m.vertices - (ones(size(m.vertices, 1), 1) * mid);
out_mesh = m;

