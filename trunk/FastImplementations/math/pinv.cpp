#include "pinv.h"

#include <limits>
#include <algorithm>

#include <boost/numeric/ublas/operation.hpp>
#include <boost/numeric/ublas/banded.hpp>

#include <boost/lambda/lambda.hpp>

#include "svd.h"


void pinv(matrix_t& a, matrix_t& result) {

	namespace ublas = boost::numeric::ublas;
	using namespace boost::lambda;

	size_t m = a.size1();
	size_t n = a.size2();

	if (n > m) {
		matrix_t at = ublas::trans(a);
		pinv(at, result);
		result = ublas::trans(result);
		return;
	}

	matrix_t u, vt;
	vector_t s;

	svd(a, u, s, vt);

	double maxSValue = *std::max_element(s.begin(), s.end());
	double tol = std::max(n, m) * std::numeric_limits<double>::epsilon() * maxSValue;

	size_t rank = std::count_if(s.begin(), s.end(), _1 > tol);

	std::for_each(s.begin(), s.end(), _1 = 1.0 / _1);
	
	//U(:, 1:r) * s * VT(1:r, :)
	u.resize(u.size1(), rank);
	vt.resize(rank, vt.size2());
	ublas::banded_matrix<double, ublas::column_major> sm(rank, rank);
	for (size_t i = 0; i < rank; ++i) {
		sm(i, i) = s(i);
	}

	result = trans(prod(u, matrix_t(prod(sm, vt))));
}
