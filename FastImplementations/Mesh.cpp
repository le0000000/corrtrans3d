#include "Mesh.h"

#include <set>
#include <queue>
#include <iostream>

#include <boost/graph/adjacency_iterator.hpp>
#include <boost/graph/dijkstra_shortest_paths.hpp>
#include <boost/tuple/tuple.hpp>

using namespace boost;
using namespace std;

class SortedEdge : public std::pair<int, int> {
public:
	SortedEdge() {}
	SortedEdge(int v1, int v2) : std::pair<int, int>(v1, v2) {
		if (first > second) {
			std::swap(first, second);
		}
	}

	// compares lexicographically
	bool operator<(const SortedEdge& other) const {
		return *(long long*)this < *(long long*)&other;
	}
};


Mesh::Mesh(const Coordinate* coordinates, size_t nCoordinates, const Face* faces, size_t nFaces)
	: m_coordinates(coordinates)
{

	typedef std::set<SortedEdge> EdgesSet;
	// extract edges from faces
	EdgesSet edgesSet;
	for (size_t i = 0; i < nFaces; ++i) {
		// note that vertices are given as 1..nvertex and not 0..nvertex-1
		edgesSet.insert(SortedEdge(faces[i].v1, faces[i].v2));
		edgesSet.insert(SortedEdge(faces[i].v2, faces[i].v3));
		edgesSet.insert(SortedEdge(faces[i].v3, faces[i].v1));
	}

	std::vector<Edge> edges;
	for (EdgesSet::const_iterator it = edgesSet.begin(); it != edgesSet.end(); ++it) {
		edges.push_back(Edge(Coordinate::distance(coordinates[it->first], coordinates[it->second])));
	}

	m_mesh_graph.reset(new graph_t(nCoordinates));

	for (size_t i = 0; i < nCoordinates; ++i) {
		(*m_mesh_graph)[i].coordinatesIndex = i;
	}

	size_t i = 0;
	for (EdgesSet::const_iterator it = edgesSet.begin(); it != edgesSet.end(); ++it, ++i) {
		add_edge(it->first, it->second, edges[i], *m_mesh_graph);
	}

	//cout << "vertices[0].coord = " << vertices[0].coordinatesIndex << endl;
	//cout << "g[0].coord = " << (*m_mesh_graph)[0].coordinatesIndex << endl;
}

const Coordinate& Mesh::vertex(int index) const {
	size_t coordInd = (*m_mesh_graph)[index].coordinatesIndex;
	//cout << "index = " << index << endl;
	//cout << "coord = " << coordInd << endl;
	return m_coordinates[coordInd];
}


void Mesh::computeGeodesicDistances(int sourceVertex, double* distances) const {
	dijkstra_shortest_paths(*m_mesh_graph, sourceVertex,
		weight_map(get(&Edge::distance, *m_mesh_graph)).distance_map(distances));
}

size_t Mesh::nVertices() const {
	return num_vertices(*m_mesh_graph);
}


void Mesh::getNeighbors(int sourceVertex, int depth, std::vector<int>& neighbors) const {
	
	static std::vector<int> bfsDistance;

	if (bfsDistance.empty()) {
		bfsDistance.resize(nVertices(), -1);
	}

	std::queue<int> nextVertices;
	nextVertices.push(sourceVertex);
	bfsDistance[sourceVertex] = 0;
	neighbors.push_back(sourceVertex);

	//cout << out_degree(sourceVertex, *m_mesh_graph) << endl;

	int currentVertex = nextVertices.back();
	int currentDistance = bfsDistance[currentVertex];

	while (currentDistance < depth) {
		graph_traits<graph_t>::adjacency_iterator beg, end;
		tie(beg, end) = adjacent_vertices(currentVertex, *m_mesh_graph);

		for ( ; beg != end; ++beg) {
			int v = *beg;
			if (bfsDistance[v] == -1) {
				nextVertices.push(v);
				neighbors.push_back(v);
				bfsDistance[v] = currentDistance + 1;
			}
		}

		
		nextVertices.pop();
		if (nextVertices.empty()) {
			break;
		}

		currentVertex = nextVertices.front();
		currentDistance = bfsDistance[currentVertex];
	}

	// clean up
	for (size_t i = 0; i < neighbors.size(); ++i) {
		bfsDistance[neighbors[i]] = -1;
	}

}

Mesh Mesh::getSubMesh(const std::vector<int>& vertices) const {

	static std::vector<int> vertexReverseMapping;

	if (vertexReverseMapping.empty()) {
		vertexReverseMapping.resize(nVertices(), -1);
	}

	for (size_t i = 0; i < vertices.size(); ++i) {
		vertexReverseMapping[vertices[i]] = i;
	}

	Mesh result;

	result.m_coordinates = m_coordinates;
	result.m_mesh_graph.reset(new graph_t(vertices.size()));
	for (size_t i = 0; i < vertices.size(); ++i) {
		(*result.m_mesh_graph)[i] = (*m_mesh_graph)[vertices[i]];
		//add_vertex((*m_mesh_graph)[vertices[i]], *result.m_mesh_graph);
	}
	
	for (size_t i = 0; i < vertices.size(); ++i) {
		graph_traits<graph_t>::out_edge_iterator beg, end;
		tie(beg, end) = out_edges(vertices[i], *m_mesh_graph);
		for ( ; beg != end; ++beg) {
			graph_traits<graph_t>::edge_descriptor e = *beg;
			int t = target(e, *m_mesh_graph);
			if (vertexReverseMapping[t] != -1) {
				add_edge(i, vertexReverseMapping[t], (*m_mesh_graph)[e], *result.m_mesh_graph);
			}
		}
	}

	for (size_t i = 0; i < vertices.size(); ++i) {
		vertexReverseMapping[vertices[i]] = -1;
	}

	return result;
}

