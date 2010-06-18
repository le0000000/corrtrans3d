function [keyVertices] = findKeyVertices(X, F, nKeyVertices)

	if libisloaded('FastImplementations') == 0
		loadlibrary('FastImplementations\Release\FastImplementations.dll', 'FastImplementations\fast_implementations.h');
	end

	keyVertices = calllib('FastImplementations', 'findKeyVertices', zeros(nKeyVertices, 1), X', F', size(X, 1), size(F, 1), nKeyVertices);
		