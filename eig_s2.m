%
% This function has the same syntax as eig(), but it returns
% the eigenvectors and eigenvalues sorted
%
% [E, D] = eig_s(A, opt)
%
% if opt = 'a', then sorting is ascending
% if opt = 'd', then sorting is descending
%
% -----------------------------------------------------------
% (C) Richard (Hao) Zhang (2004)
%
function [E, D] = eig_s(A, opt, k)

% get eigenvectors and eigenvalues unsorted

% pass options struct to indicate 0 level diagnostic output
opt_struct = struct('disp', 0);
% absence of sigma requires to return K largest eigenvalues, so by default sigma can be 'LM' - largest magnitude
[Eu, D] = eigs(A, k, 'LM', opt_struct);

d = diag(D);
[ds, p] = sort(d);

if opt == 'a'
  for i=1:k
    D(i,i) = ds(i);
    E(:, i) = Eu(:, p(i));
  end
elseif opt == 'd'
  for i=1:k
    D(i,i) = ds(k+1-i);
    E(:, i) = Eu(:, p(k+1-i));
  end
end

