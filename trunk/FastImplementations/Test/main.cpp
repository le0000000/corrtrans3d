#include <Windows.h>

#include "Mesh.h"

#include <iostream>
#include <stdexcept>
#include <ctime>

using std::cout;
using std::endl;

class Lib {
public:

	Lib() {
#ifdef NDEBUG
		m_libHandle = LoadLibraryA("FastImplementations.dll");
#else
		m_libHandle = LoadLibraryA("../Debug/FastImplementations.dll");
#endif
		if (!m_libHandle) {
			throw std::runtime_error("Failed to load DLL library");
		}

		computeGeodesic = (computeGeodesicT)GetProcAddress(m_libHandle, "computeGeodesic");
		cEigs = (cEigsT)GetProcAddress(m_libHandle, "cEigs");
		computeWeights = (computeWeightsT)GetProcAddress(m_libHandle, "constructWeights");
		getLastSparseMatrix = (getLastSparseMatrixT)GetProcAddress(m_libHandle, "getLastSparseMatrix");

		if (!computeGeodesic || !cEigs || !computeWeights) {
			throw std::runtime_error("Failed to find functions");
		}
	}

	~Lib() {
		FreeLibrary(m_libHandle);
	}
	
	typedef int (__stdcall *computeWeightsT)(const double* , const int*, int, int, int, int);
	typedef void (__stdcall *computeGeodesicT)(double*, const double* , const int*, int, int);
	typedef void (__stdcall *cEigsT)(double*, double*, const double* , int, int);
	typedef void (__stdcall *getLastSparseMatrixT)(int* rowIndices, int* colIndices, double* values, int* m, int* n);
	
	static computeGeodesicT computeGeodesic;
	static cEigsT cEigs;
	static computeWeightsT computeWeights;
	static getLastSparseMatrixT getLastSparseMatrix;

private:

	HMODULE m_libHandle;
};

Lib::computeGeodesicT Lib::computeGeodesic = NULL;
Lib::cEigsT Lib::cEigs = NULL;
Lib::computeWeightsT Lib::computeWeights = NULL;
Lib::getLastSparseMatrixT Lib::getLastSparseMatrix = NULL;

Lib lib;

void initLibrary() {
}

void testEigs(int n, int k) {

//	cout << "Entering..." << endl;

	//int n = 20 + rand() % 10, k = 4;
	double* mat = new double[n * n];
	double* vec = new double[n * k];
	double* val = new double[k];

	for (size_t i = 0; i < n; ++i) {
		for (size_t j = 0; j <= i; ++j) {
			mat[i * n + j] = (double)rand() / RAND_MAX;
			mat[j * n + i] = mat[i * n + j];
		}
	}

//	cout << "Calling cEigs..." << endl;
	Lib::cEigs(vec, val, mat, n, k);
//	cout << "After cEigs..." << endl;

	delete [] mat;
	delete [] vec;
	delete [] val;

//	cout << "Exiting..." << endl;

}

void testGeodesic() {

	Mesh m("../../meshes/alien.smf");

	std::vector<double> distances(m.vertices().size() * m.vertices().size());

	clock_t t = clock();

	Lib::computeGeodesic(&distances[0], &(m.vertices()[0].x), m.faces()[0].vertices, m.vertices().size(), m.faces().size());

	std::cout << double(clock() - t) / CLOCKS_PER_SEC << std::endl;

}

void testSpectralEmbedding() {

}

void testComputeWeights() {

	cout << "starting..." << endl;

	Mesh mesh("../../meshes/dog1.smf");


	int nnz = Lib::computeWeights(&(mesh.vertices()[0].x), mesh.faces()[0].vertices,
		mesh.vertices().size(), mesh.faces().size(), 2, 2);

	cout << "nnz = " << nnz << endl;

	std::vector<int> rows(nnz);
	std::vector<int> cols(nnz);
	std::vector<double> vals(nnz);
	int m;
	int n;

	Lib::getLastSparseMatrix(&rows[0], &cols[0], &vals[0], &m, &n);

	cout << m << "x" << n << endl;
}

int main(int argc, char* argv[]) {

	testComputeWeights();

	return 0;

	cout << "Starting..." << endl;

	if (argc != 3) {
		cout << "Usage:  Test.exe n k" << endl;
	}

	testEigs(atoi(argv[1]), atoi(argv[2]));

}
