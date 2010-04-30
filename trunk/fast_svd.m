function [E, D] = fast_svd(M, k, nyst)

subs = round(size(M,1)/nyst);
find = 1:size(M,1);

ind1 = 1:subs:size(M,1);
ind2 = setdiff(find, ind1);

p = randperm(size(M,1));
ind1 = p(ind1);
ind2 = p(ind2);

A = M(ind1, ind1);
B = M(ind1, ind2);

% Nystrom
n = size(B,1);
m = size(B,2);
Up = [A;B'];


d1 = sum(Up, 1);
d2 = sum(B,1) + sum(B,2)'*pinv(A)*B;
dhat = sqrt(1./[d1 d2])';

A = A.*(dhat(1:n)*dhat(1:n)');
B = B.*(dhat(1:n)*dhat(n+(1:m))');

Asi = sqrtm(pinv(A));
Q = A+Asi*(B*B')*Asi;

if (true)
    %[U L] = eig(Q);
    [U,L,T] = svd(Q);
else
    opts.issym = 1;
    [U L]  = eigs(Q,k+1,'lm',opts) ;
end
% V = [A;B']*Asi*U*pinv(sqrt(L));
V = Up*(Asi*U*diag(1./sqrt(abs(diag(L)))));

E=[]; res=[]; pres=[]; D=[];
for i = 2:k+1
    res = V(:,i)./V(:,1);
    pres(ind1) = res(1:n);
    pres(ind2) = res(n+1:end);
    E(:,i-1) = real(pres);
end
D = diag(L);
D = real(D(2:k+1));
D = diag(D);
