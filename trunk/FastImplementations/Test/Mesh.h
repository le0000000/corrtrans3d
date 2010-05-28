#ifndef _MESH_H_
#define _MESH_H_

#include <string>
#include <vector>
#include <algorithm>

class Mesh {
public:

	Mesh() {}

	Mesh(const std::string& smfFilename);

	struct Vertex {
		Vertex() {}
		Vertex(double x_, double y_, double z_)
			: x(x_), y(y_), z(z_) {}

		double x;
		double y;
		double z;
	};

	struct Face {
		Face() {}
		Face(int v1, int v2, int v3) {
			vertices[0] = v1;
			vertices[1] = v1;
			vertices[2] = v3;
		}
		Face(int vs[]) {
			std::copy(vs, vs + 3, vertices);
		}

		int vertices[3];
	};

	inline std::vector<Vertex>& vertices() {
		return m_vertices;
	}

	inline std::vector<Face>& faces() {
		return m_faces;
	}


private:

	std::vector<Vertex> m_vertices;
	std::vector<Face> m_faces;

};

#endif
