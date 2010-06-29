function [W] = cConstructWeights(X, F, depth)

	if libisloaded('FastImplementations') == 0
		loadlibrary('FastImplementations\Release\FastImplementations.dll', 'FastImplementations\fast_implementations.h');
	end

	nnz = calllib('FastImplementations', 'constructWeights', X', F' - 1, size(X, 1), size(F, 1), depth, 2);
	[i j s m n] = calllib('FastImplementations', 'getLastSparseMatrix', ...
			zeros(nnz, 1, 'int32'), zeros(nnz, 1, 'int32'), zeros(nnz, 1), 0, 0);
	
	W = sparse(double(i + 1), double(j + 1), s, double(m), double(n));
