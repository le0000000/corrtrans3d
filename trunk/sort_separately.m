function [X,Y,Z] = sort_separately(vector)
% Given a nx3 vector the function sorts the X,Y,Z coordinates separately
% and returns three vectors of indices sorted by the appropriate
% coordinate. For example, vector(X(i),1) <= vector(X(i+1),1), etc.

[sorted, X] = sort(vector(:,1),1,'ascend');
[sorted, Y] = sort(vector(:,2),1,'ascend');
[sorted, Z] = sort(vector(:,3),1,'ascend');