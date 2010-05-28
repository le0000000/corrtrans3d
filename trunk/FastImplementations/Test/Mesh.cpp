#include "Mesh.h"
#include <stdexcept>

template <typename T, typename F>
void tokenize(char* s, T* values, size_t maxCount, F converter) {
	char* tok = strtok(s, " ");
	size_t nTokens = 0;

	while (tok && (nTokens < maxCount)) {
		values[nTokens] = converter(tok);
		nTokens++;
		tok = strtok(NULL, " ");
	}
}

Mesh::Mesh(const std::string& smfFilename) {

	FILE* file = fopen(smfFilename.c_str(), "r");
	if (!file) {
		throw std::invalid_argument("Failed to open file for reading");
	}

	char line[256];
	int ret = fscanf(file, "%[^\n]", line);
	while (ret > 0) {

		if (line[0] == 'v') {
			Vertex v;
			tokenize(line + 2, &v.x, 3, atof);
			m_vertices.push_back(v);
		} else if (line[0] == 'f') {
			Face f;
			tokenize(line + 2, f.vertices, 3, atoi);
			m_faces.push_back(f);
		}

		getc(file);
		ret = fscanf(file, "%[^\n]", line);
	}

	fclose(file);

}

void Mesh::save( const std::string& smfFilename )
{
//	ofstream file(smfFilename.c_str());

	for (size_t i = 0; i < m_vertices.size(); ++i) {
		// file << "v " << m_vertices[i].x << " " << m_vertices[i].y << " " << m_vertices[i].z << " ";
		
	}
}
