#include "djkstra.h"

#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/dijkstra_shortest_paths.hpp>

using namespace boost;

void djkstra(const std::set<Edge>& edges, const std::vector<double>& weights, int nvertices, double* distances) {

	// define a type for undirected weighted graph
	typedef adjacency_list < listS, vecS, undirectedS,
		no_property, property < edge_weight_t, double > > graph_t;

	// create a graph from the edges list and weights list
	graph_t g(edges.begin(), edges.end(), weights.begin(), nvertices);

	// array to hold the shortest distances
	std::vector<double> dist(nvertices);

	// for each vertex...
	for (int i = 0; i < nvertices; ++i) {
		// run dijkstra
		dijkstra_shortest_paths(g, vertex(i, g), distance_map(&dist[0]));

		// copy the shortest paths to i'th row of the result matrix
		std::copy(dist.begin(), dist.end(), distances + i * nvertices);
	}

}
