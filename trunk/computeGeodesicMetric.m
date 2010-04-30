function [A] = computeGeodesicMetric(X, F)

	if libisloaded('FastImplementations') == 0
		loadlibrary('FastImplementations\Release\FastImplementations.dll', 'FastImplementations\fast_implementations.h');
	end
	
	A = calllib('FastImplementations', 'computeGeodesic', zeros(size(X, 1)), X', F', size(X, 1), size(F, 1));
	