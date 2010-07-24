#include "WeightsComputation.h"

#include <vector>
#include <algorithm>
#include <iterator>
#include <iostream>
#include <fstream>

#include <boost/numeric/ublas/matrix_proxy.hpp>
#include <boost/numeric/ublas/io.hpp>

#include "math/svd.h"
#include "math/pinv.h"
#include "SpectralEmbedding.h"

namespace ublas = boost::numeric::ublas;

namespace WeightsComputation {

	void noProcessing(const Mesh& mesh, const std::vector<int>& neighbors, matrix_t& newCoordinates) {

		newCoordinates.resize(neighbors.size(), 3);
		for (size_t i = 0; i < neighbors.size(); ++i) {
			const Coordinate& c = mesh.vertex(neighbors[i]);
			newCoordinates(i, 0) = c.x;
			newCoordinates(i, 1) = c.y;
			newCoordinates(i, 2) = c.z;
		}

	}

	void pcaProcessing(const Mesh& mesh, const std::vector<int>& neighbors, matrix_t& newCoordinates) {

		using namespace ublas;

		static vector_t newSourceCoords;
		static matrix_t newNeighborsCoords;
		static matrix_t neighborsCoords;
		static vector_t sourceCoords;
		static matrix_t svdInput;
		static matrix_t u, vt; // for svd output
		static vector_t s;

		neighborsCoords.resize(neighbors.size() - 1, 3);
		for (size_t i = 1; i < neighbors.size(); ++i) {
			const Coordinate& c = mesh.vertex(neighbors[i]);
			neighborsCoords(i - 1, 0) = c.x;
			neighborsCoords(i - 1, 1) = c.y;
			neighborsCoords(i - 1, 2) = c.z;
		}
		
		const Coordinate& c = mesh.vertex(neighbors[0]);
		sourceCoords.resize(3);
		sourceCoords(0) = c.x;
		sourceCoords(1) = c.y;
		sourceCoords(2) = c.z;

		// required since svd destroys contents of the input matrix
		svdInput = neighborsCoords; 

		svd(svdInput, u, s, vt);

		vt.resize(2, vt.size2());
		vt = ublas::trans(vt);

		newNeighborsCoords = ublas::prod(neighborsCoords, vt);
		newSourceCoords = ublas::prod(sourceCoords, vt);

		newCoordinates.resize(neighbors.size(), 2);
		for (size_t i = 0; i < newCoordinates.size2(); ++i) {
			ublas::matrix_column<matrix_t> col = ublas::column(newNeighborsCoords, i);
			std::copy(col.begin(), col.end(), ublas::column(newCoordinates, i).begin() + 1);
			newCoordinates(0, i) = newSourceCoords(i);
		}

	}

	void geodesicProcessing(const Mesh& mesh, const std::vector<int>& neighbors, matrix_t& newCoordinates) {

		static std::vector<Coordinate> embeddedCoords;
		embeddedCoords.resize(neighbors.size());

		newCoordinates.resize(neighbors.size(), 3);

		try {

			Mesh submesh = mesh.getSubMesh(neighbors);
			spectralEmbedding(submesh, &embeddedCoords[0]);

			for (size_t i = 0; i < neighbors.size(); ++i) {
				newCoordinates(i, 0) = embeddedCoords[i].x;
				newCoordinates(i, 1) = embeddedCoords[i].y;
				newCoordinates(i, 2) = embeddedCoords[i].z;
			}

		} catch (std::exception& e) {
			std::ofstream f("d:\\tmp\\weight_exception");
			f << e.what();
		}

	}

}

void computeMeshWeights(const Mesh& mesh, int depth, process_neighbors_f op, sparse_matrix_t& weights) {

	using namespace ublas;

	matrix_t newCoordinates;
	size_t nvertices = mesh.nVertices();

	matrix_t weightsSystemMatrix;
	matrix_t weightsSystemInvMatrix;
	vector_t weightsSystemFree;
	vector_t weightsSystemSol;

	weights.clear();
	weights.resize(nvertices, nvertices, false);

	for (int i = 0; i < (int)nvertices; ++i) {
		// get neighbors
		std::vector<int> neighbors;
		mesh.getNeighbors(i, depth, neighbors);

		// apply processing on the neighbors coordinates
		op(mesh, neighbors, newCoordinates);

		//exit(0);

		// build the equation set to compute the weights

		// build the matrix
		weightsSystemMatrix.resize(newCoordinates.size1() - 1, newCoordinates.size2() + 1);
		for (size_t j = 0; j < newCoordinates.size2(); ++j) {
			matrix_column<matrix_t> sysCol = column(weightsSystemMatrix, j);
			matrix_column<matrix_t> coordsCol = column(newCoordinates, j);
			std::copy(coordsCol.begin() + 1, coordsCol.end(), sysCol.begin());
		}
		ublas::matrix_column<matrix_t> lastCol = column(weightsSystemMatrix, weightsSystemMatrix.size2() - 1);
		std::fill(lastCol.begin(), lastCol.end(), 1.0);

		// build the free vector
		weightsSystemFree.resize(newCoordinates.size2() + 1);
		ublas::matrix_row<matrix_t> firstRow = row(newCoordinates, 0);
		std::copy(firstRow.begin(), firstRow.end(), weightsSystemFree.begin());
		weightsSystemFree(weightsSystemFree.size() - 1) = 1.0;

		// solve equation set
		pinv(weightsSystemMatrix, weightsSystemInvMatrix);
		weightsSystemSol = prod(weightsSystemFree, weightsSystemInvMatrix);

		// copy the solution to weights matrix
		for (size_t j = 0; j < weightsSystemSol.size(); ++j) {
			weights(i, neighbors[j + 1]) = weightsSystemSol(j);
		}
	}

}
