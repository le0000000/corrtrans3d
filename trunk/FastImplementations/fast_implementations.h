#ifndef _FAST_IMPLEMENTATIONS_H_
#define _FAST_IMPLEMENTATIONS_H_

void __stdcall computeGeodesic(double* distances, const double* vertices, 
								 const int* faces, int nvertices, int nfaces);

int __stdcall reduceMesh(double* vertices, int* faces, int nvertices, int nfaces, int reducedVertices);

#endif
