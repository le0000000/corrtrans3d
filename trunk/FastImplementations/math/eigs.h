#ifndef _EIGS_H_
#define _EIGS_H_

#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/vector.hpp>

enum EigsMode {
	EIGS_LARGEST, EIGS_SMALLEST
};

template <typename MAT, typename VECS, typename VALS>
void eigs(VECS& eigVec, VALS& eigVal, const MAT& mat, size_t k, EigsMode mode = EIGS_LARGEST);


#include "eigs.inl"

#endif
