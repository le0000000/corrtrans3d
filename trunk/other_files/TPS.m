%
% Implementation of thin-plate splines for aligning two point sets in 3D
% (the code should work for n-D, but it was only tested in 3D).
%
% [w d M V] = TPS(X, V, F1, F2)
%
% Input:
%   - X: <n x 3> matrix defining first point set
%   - V: <m x 3> matrix defining the second point set
%   - F1, F2: face lists which were used for experimentation and can be
%   omitted.
%
% Output:
%   w and d are the TPS transformation parameters
%   - d: <4 x 4> rigid transformation matrix 
%   - w: <m x 4> scaling factor matrix
%   - M: <n x m> matrix which represents the final correspondence
%   between point sets X and V. M(i, j) = 1 if point 'i' on mesh 1
%   matches to point 'j' in mesh 2
%   - V: transformed version of input V, so that V is now aligned with
%   the point set X
%
function [w d M V] = TPS(X, V, F1, F2)

    N = length(X(:,1));
    K = length(V(:,1));
    lambda = (sum(sum(computePairwise(V)))/(K*K))^2;
    dim = length(X(1,:));
    V_init = V;
    
    M = ones(N, K);
    d = eye(dim+1, dim+1);
    w = zeros(K, dim+1);
    phi = findPhi(V_init);
    for i = 1:10
        V = nonRigidTransform(V_init, d, w, phi);
        M = updateM(X, V, lambda);
        [d w] = updateTransform(X, V_init, M, d, w, lambda, dim, phi);
        lambda = lambda * 0.97;
        lambda = (sum(sum(computePairwise(V)))/(K*K))^2;
        %disp(lambda);
    %if mod(i-1,5) == 0
    %figure;
    %set(trisurf(F1, X(:,1), X(:,2), X(:,3),2), 'FaceAlpha', 0.5);
    %hold on;
    %set(trisurf(F2, V(:,1), V(:,2), V(:,3),3), 'FaceAlpha', 0.5);
    %axis equal;
    %end
    end
    V = nonRigidTransform(V_init, d, w, phi);
%------------------------------------------------
function phi = findPhi(Y)

    [n dim] = size(Y);
    phi = zeros(n,n);
    for i=1:dim
      tmp = Y(:,i) * ones(1,n) - ones(n,1) * Y(:,i)';
      tmp = tmp .* tmp;
      phi = phi + tmp;
    end;
    phi = - sqrt(phi);
%------------------------------------------------
function fv = nonRigidTransform(v, d, w, phi)

    [K dim] = size(v);
    %phi = findPhi(v);
    v = [v ones(K,1)];
    fv = v * d + phi * w;
    %fv = v*d;
    fv = fv(:,1:dim);
%----------------------------------------------------
function M = updateM(X, V, lambda)

    [n dim] = size(V);
    m = length(X(:,1));
    S = zeros(n,m);
    for i=1:dim
      tmp = V(:,i) * ones(1,m) - ones(n,1) * X(:,i)';
      tmp = tmp .* tmp;
      S = S + tmp;
    end;
    %K = hungarian(S);
    %M = zeros(n,m);
    %for i = 1:n
    %    M(i,K(i)) = 1;
    %end
    %return
    M = zeros(n,m);
    for i = 1:n
        [junk idx] = min(S(i,:));
        M(i,idx(1)) = 1;
    end
    
    %sig = max(max(sqrt(S)))/100;
    %sig = 1/(10*lambda);
    %M = exp(-S/(2*sig*sig));
    %M = ones(n,m)./sqrt(S);
    
    %M = normalizeRowColSum(M);
%-----------------------------------------------------
function [d w] = updateTransform(X, V, M, d, w, lambda, dim, phi)

    N = length(X(:,1));
    K = length(V(:,1));
    for i = 1:K
        Y(i,:) = (M(i,:)*X)/sum(M(i,:));
    end
    Y = [Y ones(K,1)];
    V = [V ones(K,1)];
    %[Q1 Q2 R] = qrDecompose(V);
    phi = phi+ lambda*eye(K);
    
    %w = Q2 * inv(Q2'*phi*Q2 + lambda*eye(K-dim-1)) * Q2'*Y;
    %w = inv(phi + lambda*eye(K) - Q1*Q1'*phi) * (Y - Q1*Q1'*Y);
    %w = inv(phi)*Y;
    %d = inv(R)* Q1' * (Y - phi*w);
    %d = inv(V'*V)*V'*Y;
    [phi V; V' zeros(dim+1,dim+1)];
    junk = ([phi V; V' zeros(dim+1,dim+1)])\[Y;zeros(dim+1,dim+1)];
    w = junk(1:K,:);
    d = junk(K+1:K+dim+1,:);
%------------------------------------------------------
function [Q1 Q2 R] = qrDecompose(x)

    [n,m] = size (x);

    [q,r]   = qr(x);
    Q1      = q(:, 1:m);
    Q2      = q(:, m+1:n);
    R       = r(1:m,1:m);
%---------------------------------------------------------------
function M = normalizeRowColSum(M)

    [n m] = size(M);
    for i = 1:50
        % --- Row normalization --------------------------------------------
        sx = sum(M')';
        M  = M ./ (sx * ones(1,m));
  
        % --- Column normalization -----------------------------------------
        sy = sum(M);
        M  = M ./ (ones(n,1)*sy);
%        for j = 1:n
%            s = sum(M(j,:));
%            M(j,:) = M(j,:)/s;
%            if sum(M(j,:)) ~= 1
%                disp('error');
%            end
%        end
%        for j = 1:m
%            s = sum(M(:,j));
%            M(:,j) = M(:,j)/s;
%            if sum(M(:,j)) ~= 1
%                disp('error');
%            end
%        end
    end
