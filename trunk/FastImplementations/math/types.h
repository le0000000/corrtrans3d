#ifndef _MATH_TYPES_H_
#define _MATH_TYPES_H_

#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/vector.hpp>

typedef boost::numeric::ublas::matrix<double, boost::numeric::ublas::column_major> matrix_t;
typedef boost::numeric::ublas::vector<double> vector_t;

#endif
