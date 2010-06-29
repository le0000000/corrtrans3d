function [e_vector, e_value] = rayleigh_iteration(A, mu_0, v_0, epsilon)
% Applies the Rayleigh quotient iteration to find an eigenvalue and an
% eigenvector based on their initial guesses. At each step both eigenvalue
% and eigenvector are recalculated, until the eigenvector series converges
% (up to the provided epsilon); the rate of convergence is cubic and
% therefore very fast.
% We assume that v_0 is a column vector and that A is square.

% normalize v_0
% v_i and mu_i are the vectors of the previous iteration
v_i = v_0 ./ norm(v_0); % (v_0' * v_0);
mu_i = mu_0;

n = size(A, 1);

% initialize error to 0 only iff v_0 is allready an eigenvector with
% eigenvalue mu_0
error = norm(A * v_0 - mu_0 .* v_0);
% disp('Initial error');
% disp(error);

while error > epsilon
   % calculate v_i1 (using the \ operator)
   v_i1 = (A - (eye(n) .* mu_i)) \ (v_i);
   % normalize v_i1
   v_i1 = v_i1 ./ norm(v_i1);
   % calculate mu_i1
   mu_i1 = v_i1' * A * v_i1;
   disp('Mu:');
   disp(mu_i1);
   % error is the difference between (normalized) v_i and v_i1
   error = norm(v_i - v_i1);
   disp('Error:');
   disp(error);
   %convert current to previous
   v_i = v_i1;
   mu_i = mu_i1;
end

e_vector = v_i;
e_value = mu_i;