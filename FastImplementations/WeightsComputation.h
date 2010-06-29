#ifndef _WEIGHTS_COMPUTATION_H_
#define _WEIGHTS_COMPUTATION_H_

#include <boost/numeric/ublas/matrix_sparse.hpp>

#include "math/types.h"
#include "Mesh.h"

typedef boost::numeric::ublas::compressed_matrix<double, boost::numeric::ublas::column_major> sparse_matrix_t;

typedef void (*process_neighbors_f)(const Mesh& mesh, const std::vector<int>& neighbors, matrix_t& newCoordinates);


namespace WeightsComputation {

	void noProcessing(const Mesh& mesh, const std::vector<int>& neighbors, matrix_t& newCoordinates);

	void pcaProcessing(const Mesh& mesh, const std::vector<int>& neighbors, matrix_t& newCoordinates);

	void geodesicProcessing(const Mesh& mesh, const std::vector<int>& neighbors, matrix_t& newCoordinates);

}

void computeMeshWeights(const Mesh& mesh, int depth, process_neighbors_f op, sparse_matrix_t& weights);

#endif
