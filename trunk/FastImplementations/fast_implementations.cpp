#include <cmath>
#include <fstream>
#include <utility>
#include <set>
#include <vector>
#include <queue>

#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/dijkstra_shortest_paths.hpp>

using namespace std;
using namespace boost;

/**
 * Edge - sorted pair of vertices.
 */
class Edge : public std::pair<int, int> {
public:
	Edge() {}
	Edge(int v1, int v2) : std::pair<int, int>(v1, v2) {
		if (first > second) {
			std::swap(first, second);
		}
	}

	// compares lexicographically
	bool operator<(const Edge& other) const {
		return *(long long*)this < *(long long*)&other;
	}
};

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

	// define a type for undirected weighted graph
	typedef adjacency_list < listS, vecS, undirectedS,
		no_property, property < edge_weight_t, double > > graph_t;

	// create a graph from the edges list and weights list
	graph_t g(edges.begin(), edges.end(), weights.begin(), nvertices);

	// array to hold the shortest distances
	std::vector<double> dist(nvertices);

	// for each vertex...
	for (i = 0; i < nvertices; ++i) {
		// run dijkstra
		dijkstra_shortest_paths(g, vertex(i, g), distance_map(&dist[0]));

		// copy the shortest paths to i'th row of the result matrix
		std::copy(dist.begin(), dist.end(), distances + i * nvertices);
	}

}
