function [m_out] = cTransformUsingSE(m)

	if libisloaded('FastImplementations') == 0
		loadlibrary('FastImplementations\Release\FastImplementations.dll', 'FastImplementations\fast_implementations.h');
	end
	X = m.vertices;
	F = m.faces;
	
	m_out.vertices = calllib('FastImplementations', 'computeSpectralEmbedding', zeros(size(X))', X', F' - 1, size(X, 1), size(F, 1))';
	m_out.faces = F;
