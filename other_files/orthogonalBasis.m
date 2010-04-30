function [B] = orthogonalBasis(A)

	B = A;
	
	B(:, 1) = B(:, 1) / norm(B(:, 1));
	for i = 2:size(B, 2)
		v = B(:, i);
		for j = 1:i-1
			u = B(:, j);
			v = v - (u' * v) * u;
		end
		nrm = norm(v)
		if abs(nrm) < 1e-8
			nrm = 1;
		end
		B(:, i) = v / nrm;
	end
	