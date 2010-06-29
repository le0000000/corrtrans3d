#include "SpectralEmbedding.h"

#include <cmath>

#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/matrix_proxy.hpp>
#include <boost/foreach.hpp>

#include "math/eigs.h"

namespace ublas = boost::numeric::ublas;

typedef ublas::matrix<double> matrix_t;

static void applyGaussian(matrix_t& m) {
	matrix_t::array_type& arr = m.data();
	double sig = *std::max_element(arr.begin(), arr.end());

	BOOST_FOREACH(double& v, arr) {
		v = std::exp(-v * v / (2 * sig * sig));
	}
}

void spectralEmbedding(const Mesh& mesh, Coordinate* resultCoordinates) {

	size_t n = mesh.nVertices();

	matrix_t geodesicDistances(n, n);

	for (size_t i = 0; i < n; ++i) {
		mesh.computeGeodesicDistances(i, &geodesicDistances(i, 0));
	}

	applyGaussian(geodesicDistances);

	matrix_t eigVectors(n, 4);
	std::vector<double> eigValues(4);

	eigs(eigVectors, eigValues, geodesicDistances, 4);	

	for (size_t i = 0; i < eigVectors.size2() - 1; ++i) {
		ublas::matrix_column<matrix_t> col(eigVectors, i);
		col *= std::sqrt(std::abs(eigValues[i]));
	}
	
	for (size_t i = 0; i < eigVectors.size1(); ++i) {
		resultCoordinates[i].z = eigVectors(i, 0);
		resultCoordinates[i].y = eigVectors(i, 1);
		resultCoordinates[i].x = eigVectors(i, 2);
	}
}
