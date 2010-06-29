#ifndef _FAST_IMPLEMENTATIONS_H_
#define _FAST_IMPLEMENTATIONS_H_

void __stdcall computeGeodesic(double* distances, const double* vertices, 
								 const int* faces, int nvertices, int nfaces);

int __stdcall reduceMesh(double* vertices, int* faces, int nvertices, int nfaces, int reducedVertices);

void __stdcall findKeyVertices(int* keyVertexIndexes, const double* vertices, const int* faces,
							   int nvertices, int nfaces, int nKeyVertices);

void __stdcall cEigs(double* vecs, double* vals, const double* matrix, int n, int k);

void __stdcall computeSpectralEmbedding(double* outVertices, const double* vertices,
										const int* faces, int nvertices, int nfaces);

int __stdcall constructWeights(const double* vertices, const int* faces,
							   int nvertices, int nfaces, int depth, int methodId);

void __stdcall getLastSparseMatrix(int* colIndices, int* rowIndices, double* values, int* m, int* n);

#endif
