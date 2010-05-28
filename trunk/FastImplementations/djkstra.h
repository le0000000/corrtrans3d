#ifndef _DJKSTRA_H_
#define _DJKSTRA_H_

#include <utility>
#include <set>
#include <vector>

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


void djkstra(const std::set<Edge>& edges, const std::vector<double>& weights, int nvertices, double* distances);

#endif
