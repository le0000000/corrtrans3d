#ifndef _MESH_H_
#define _MESH_H_

#include <boost/graph/adjacency_list.hpp>
#include <boost/shared_ptr.hpp>

struct Coordinate {
	double x;
	double y;
	double z;

	static double distance(const Coordinate& c1, const Coordinate& c2) {
		double dx = c1.x - c2.x;
		double dy = c1.y - c2.y;
		double dz = c1.z - c2.z;
		return std::sqrt(dx * dx + dy * dy + dz * dz);
	}
};

struct Face {
	int v1;
	int v2;
	int v3;
};


class Mesh {
public:

	Mesh() {}
	Mesh(const Coordinate* coordinates, size_t nCoordinates, const Face* faces, size_t nFaces);
	
	size_t nVertices() const;

	const Coordinate& vertex(int index) const;


	Mesh getSubMesh(const std::vector<int>& vertices) const;

	void computeGeodesicDistances(int sourceVertex, double* distances) const;

	void getNeighbors(int sourceVertex, int depth, std::vector<int>& neighbors) const;

private:

	struct Vertex {
		Vertex() {}
		Vertex(size_t coordIndex) : coordinatesIndex(coordIndex) {}
		size_t coordinatesIndex;
	};

	struct Edge {
		Edge() {}
		Edge(double distance_) : distance(distance_) {}

		double distance;
	};

	typedef boost::adjacency_list< boost::listS, boost::vecS, boost::undirectedS,
		Vertex, Edge> graph_t;

	const Coordinate* m_coordinates;

	boost::shared_ptr<graph_t> m_mesh_graph;

};

#endif
