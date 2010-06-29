#include <Windows.h>

#include <cmath>
#include <set>
#include <vector>
#include <iostream>

#include "math/eigs.h"
#include "Mesh.h"
#include "MeshReduce/progmesh.h"

#include "SpectralEmbedding.h"
#include "WeightsComputation.h"

sparse_matrix_t g_sparseMatrix;


using namespace std;

struct Vertex {
	double x;
	double y;
	double z;

	static double distance(const Vertex& v1, const Vertex& v2) {
		double dx = v1.x - v2.x;
		double dy = v1.y - v2.y;
		double dz = v1.z - v2.z;
		return std::sqrt(dx * dx + dy * dy + dz * dz);
	}
};


BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD reason, LPVOID reserved) {
	if (reason == DLL_PROCESS_ATTACH) {
		std::string filename(256, '\0');
		GetModuleFileNameA(hinstDLL, &filename[0], filename.size());
		size_t parentDirEnd = filename.rfind('\\', filename.rfind('\\') - 1);
		filename.resize(parentDirEnd);
		SetDllDirectoryA(filename.c_str());

		cout << filename << endl;
	}
	return TRUE;
}

void __stdcall computeGeodesic(double* distances, const double* vertices, 
								 const int* faces, int nvertices, int nfaces)
{
	Mesh m((const Coordinate*)vertices, nvertices, (const Face*)faces, nfaces);

	for (int i = 0; i < nvertices; ++i) {
		m.computeGeodesicDistances(i, distances + i * nvertices);
	}
}

static void prepareLists(const Vertex* vs, int nvertices, const Face* fs, int nfaces,
						 MeshReduce::List<MeshReduce::Vector>& verticesList,
						 MeshReduce::List<MeshReduce::tridata>& facesList)
{
	// prepare vertices list
	for (int i = 0; i < nvertices; ++i) {
		verticesList.Add(MeshReduce::Vector((float)vs[i].x, (float)vs[i].y, (float)vs[i].z));
	}
	// prepare faces list (and covert indexes from 1-based to 0-based)
	for (int i = 0; i < nfaces; ++i) {
		MeshReduce::tridata face;
		face.v[0] = fs[i].v1 - 1;
		face.v[1] = fs[i].v2 - 1;
		face.v[2] = fs[i].v3 - 1;
		facesList.Add(face);
	}
}

void __stdcall findKeyVertices(int* keyVertexIndexes, const double* vertices, const int* faces,
							   int nvertices, int nfaces, int nKeyVertices)
{
	using namespace MeshReduce;

	// prepare input for ProgressiveMesh
	List<Vector> verticesList;
	List<tridata> facesList;

	prepareLists((const Vertex*)vertices, nvertices, (const Face*)faces, nfaces, verticesList, facesList);

	// results storage
	List<int> collapse_map;
	List<int> permutation;

	// apply the reduction alrogithm
	ProgressiveMesh(verticesList, facesList, collapse_map, permutation);

	for (int i = 0; i < nvertices; ++i) {
		if (permutation[i] < nKeyVertices) {
			keyVertexIndexes[permutation[i]] = i;
		}
	}
}

int __stdcall reduceMesh(double* vertices, int* faces, int nvertices, int nfaces, int nReducedVertices)
{
	using namespace MeshReduce;

	Vertex* vs = (Vertex*)vertices;
	Face* fs = (Face*)faces;

	// prepare input for ProgressiveMesh
	List<Vector> verticesList;
	List<tridata> facesList;
	
	prepareLists(vs, nvertices, fs, nfaces, verticesList, facesList);

	// results storage
	List<int> collapse_map;
	List<int> permutation;

	// apply the reduction alrogithm
	ProgressiveMesh(verticesList, facesList, collapse_map, permutation);

	// reorder vertices according to the returned permutation
	std::vector<Vertex> tmpVertices(vs, vs + nvertices);
	for (int i = 0; i < nvertices; ++i) {
		vs[permutation[i]] = tmpVertices[i];
	}
	// update faces to use new vertices' order
	for (int i = 0; i < nfaces * 3; ++i) {
		faces[i] = permutation[faces[i] - 1];
	}

	// create new faces based on new vertices
	int currentFace = 0;
	for (int i = 0; i < nfaces; ++i) {
		Face newFace;
		// map face's vertices to the range [0..nReducedVertices-1]
		newFace.v1 = MapVertex(fs[i].v1, nReducedVertices, collapse_map);
		newFace.v2 = MapVertex(fs[i].v2, nReducedVertices, collapse_map);
		newFace.v3 = MapVertex(fs[i].v3, nReducedVertices, collapse_map);

		// if any two vertices of the face are the same vertex now - discard the face
		if (newFace.v1 == newFace.v2 || newFace.v2 == newFace.v3 || newFace.v3 == newFace.v1) {
			continue;
		}

		// copy the new face (and covert indexes from 0-based to 1-based)
		fs[currentFace].v1 = newFace.v1 + 1;
		fs[currentFace].v2 = newFace.v2 + 1;
		fs[currentFace].v3 = newFace.v3 + 1;
		currentFace++;
	}

	return currentFace;
}

void __stdcall cEigs(double* vecs, double* vals, const double* matrix, int n, int k) {

	namespace ublas = boost::numeric::ublas;

	ublas::matrix<double, ublas::column_major> m(n ,n);
	std::copy(matrix, matrix + n * n, &m(0, 0));

	ublas::matrix<double, ublas::column_major> vc(n, k);
	ublas::vector<double> vl(k);

	//cout << "Calling eigs" << endl;
	eigs(vc, vl, m, k);
	//cout << "After eigs" << endl;

	std::copy(&vc(0, 0), (&vc(0, 0)) + n * k, vecs);
	std::copy(vl.begin(), vl.end(), vals);
}

void __stdcall computeSpectralEmbedding(double* outVertices, const double* vertices,
										const int* faces, int nvertices, int nfaces)
{
	Mesh m((const Coordinate*)vertices, nvertices, (const Face*)faces, nfaces);
	spectralEmbedding(m, (Coordinate*)outVertices);
}

int __stdcall constructWeights(const double* vertices, const int* faces,
							   int nvertices, int nfaces, int depth, int methodId)
{
	process_neighbors_f op = NULL;
	switch (methodId) {
		case 0:
			op = WeightsComputation::noProcessing;
			break;
		case 1:
			op = WeightsComputation::pcaProcessing;
			break;
		case 2:
			op = WeightsComputation::geodesicProcessing;
			break;
	}

	Mesh m((const Coordinate*)vertices, nvertices, (const Face*)faces, nfaces);
	computeMeshWeights(m, depth, op, g_sparseMatrix);

	return g_sparseMatrix.nnz();
}

void __stdcall getLastSparseMatrix(int* rowIndices, int* colIndices, double* values, int* m, int* n) {
	size_t nnz = g_sparseMatrix.nnz();
	size_t ncols = g_sparseMatrix.size2();

	const sparse_matrix_t::index_array_type& colsBases = g_sparseMatrix.index1_data();
	const sparse_matrix_t::index_array_type& rows = g_sparseMatrix.index2_data();
	const sparse_matrix_t::value_array_type& vals = g_sparseMatrix.value_data();

	std::copy(rows.begin(), rows.begin() + nnz, rowIndices);
	for (size_t i = 0; i < ncols; ++i) {
		std::fill(colIndices + colsBases[i], colIndices + colsBases[i + 1], i);
	}
	std::copy(vals.begin(), vals.begin() + nnz, values);

	*m = g_sparseMatrix.size1();
	*n = g_sparseMatrix.size2();
}
