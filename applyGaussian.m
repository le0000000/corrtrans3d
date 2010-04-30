%
% Apply a Gaussian kernel to a dissimilarity matrix
%
% G = applyGaussian(H, sig)
%
% Input:
%   - H: <n x m> dissimilarity matrix
%   - sig: width of Gaussian kernel. If the parameter is omitted, then
%   sig is set to the maximum element in abs(H).
% 
% Output:
%   - G: <n x m> matrix such that G(i, j) = exp((-H(i, j)^2)/(2*sig^2)). 
%
function G = applyGaussian(H, sig)

    if nargin == 1
        s = 1*max(max(abs(H)));    %-----Gaussian width
    else
        s = sig;
    end
    G = exp(((-1)*H.^2)/(2*s^2));   %-----Gaussian
