#include <cmath>
#include <set>
#include <vector>

#include "djkstra.h"
#include "MeshReduce/progmesh.h"

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

struct Face {
	int v1;
	int v2;
	int v3;
};


void __stdcall computeGeodesic(double* distances, const double* vertices, 
								 const int* faces, int nvertices, int nfaces)
{
	Vertex* vs = (Vertex*)vertices;
	Face* fs = (Face*)faces;

	// extract edges from faces
	std::set<Edge> edges;
	for (int i = 0; i < nfaces; ++i) {
		// note that vertices are given as 1..nvertex and not 0..nvertex-1
		edges.insert(Edge(fs[i].v1 - 1, fs[i].v2 - 1));
		edges.insert(Edge(fs[i].v2 - 1, fs[i].v3 - 1));
		edges.insert(Edge(fs[i].v3 - 1, fs[i].v1 - 1));
	}

	// calculate weights for edges
	std::vector<double> weights(edges.size());
	int i = 0;
	for (std::set<Edge>::const_iterator it = edges.begin(); it != edges.end(); ++it, ++i) {
		weights[i] = Vertex::distance(vs[it->first], vs[it->second]);
	}

	djkstra(edges, weights, nvertices, distances);
}

int __stdcall reduceMesh(double* vertices, int* faces, int nvertices, int nfaces, int nReducedVertices)
{
	using namespace MeshReduce;

	Vertex* vs = (Vertex*)vertices;
	Face* fs = (Face*)faces;

	List<Vector> verticesList;
	List<tridata> facesList;

	for (int i = 0; i < nvertices; ++i) {
		verticesList.Add(Vector((float)vs[i].x, (float)vs[i].y, (float)vs[i].z));
	}
	for (int i = 0; i < nfaces; ++i) {
		tridata face;
		face.v[0] = fs[i].v1 - 1;
		face.v[1] = fs[i].v2 - 1;
		face.v[2] = fs[i].v3 - 1;
		facesList.Add(face);
	}

	List<int> collapse_map;
	List<int> permutation;

	ProgressiveMesh(verticesList, facesList, collapse_map, permutation);

	std::vector<Vertex> tmpVertices(vs, vs + nvertices);
	for (int i = 0; i < nvertices; ++i) {
		vs[permutation[i]] = tmpVertices[i];
	}
	for (int i = 0; i < nfaces * 3; ++i) {
		faces[i] = permutation[faces[i] - 1];
	}

	int currentFace = 0;
	for (int i = 0; i < nfaces; ++i) {
		Face newFace;
		newFace.v1 = MapVertex(fs[i].v1, nReducedVertices, collapse_map);
		newFace.v2 = MapVertex(fs[i].v2, nReducedVertices, collapse_map);
		newFace.v3 = MapVertex(fs[i].v3, nReducedVertices, collapse_map);

		if (newFace.v1 == newFace.v2 || newFace.v2 == newFace.v3 || newFace.v3 == newFace.v1) {
			continue;
		}

		fs[currentFace].v1 = newFace.v1 + 1;
		fs[currentFace].v2 = newFace.v2 + 1;
		fs[currentFace].v3 = newFace.v3 + 1;
		currentFace++;
	}

	return currentFace;
}
