%function RA=pw_graph_dist(A) BY FRANK LIU
%NOTICE:
% A is the adjacency matrix. Here I assume:
% 1. i==j:     A(i,j)=0;
% 2. i adjacent to j:   A(i,j) is the cost on the edge;
% 3. i is not adjacent to j: A(i,j) is a negative number.

%compute pairwise graph distance to store it in matrix RA.

function RA=pw_graph_dist(A)
%NOTICE:
% A is the adjacency matrix. Here I assume:
% 1. i==j:     A(i,j)=0;
% 2. i adjacent to j:   A(i,j) is the cost on the edge;
% 3. i is not adjacent to j: A(i,j) is a negative number.

%compute pairwise graph distance to store it in matrix RA.
num = size(A,1);
RA = zeros(num, num);
for i=1:num
    dv = Dijkstra(i,A);
    RA(i,:)=dv';
end

%-------------------Dijkstra-----------------------%
function dv=Dijkstra(src,AM)
%src is the index of the source point and AM is the adjacency matrix
r_num = size(AM,1);
c_num = r_num;
num = r_num;
for i=1:r_num
    for j=1:c_num
        if AM(i,j)<0
            AM(i,j)=inf;
        end
    end
end

dist = zeros(num, 1);
for j=1:num
    dist(j)=AM(src,j);
end

% v labels those vertices visited.
v=zeros(num,1);
v(src)=1;

for i=1:num-1
    %choose a vertex w in V-S such that distance(w) is min.
    %S initially contains only src.
    min = inf; u=-1;
    for j=1:num
        if v(j)==0 && dist(j)<min
            min = dist(j);
            u=j;
        end
    end
    %add w to S
    v(u) = 1;
        
    %update distance array
    for k=1:num
        if v(k)==0
            if dist(k)>(dist(u)+AM(u,k))
                dist(k)=dist(u)+AM(u,k);
            end
        end
    end
end
dv = dist;