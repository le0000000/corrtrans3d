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

int __stdcall reduceMesh(double* vertices, int* faces, int nvertices, int nfaces, int reducedVertices)
{
	using namespace MeshReduce;

	Vertex* vs = (Vertex*)vertices;
	Face* fs = (Face*)faces;


}
