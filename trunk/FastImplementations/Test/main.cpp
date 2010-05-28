#include <Windows.h>

#include "Mesh.h"

#include <iostream>
#include <stdexcept>
#include <ctime>

class Lib {
public:

	Lib() {
#ifdef NDEBUG
		m_libHandle = LoadLibraryA("../Release/FastImplementations.dll");
#else
		m_libHandle = LoadLibraryA("../Debug/FastImplementations.dll");
#endif
		if (!m_libHandle) {
			throw std::runtime_error("Failed to load DLL library");
		}

		computeGeodesic = (computeGeodesicT)GetProcAddress(m_libHandle, "computeGeodesic");
		if (!computeGeodesic) {
			throw std::runtime_error("Failed to find 'computeGeodesic' function");
		}
	}

	~Lib() {
		FreeLibrary(m_libHandle);
	}
	
	typedef void (__stdcall *computeGeodesicT)(double*, const double* , const int*, int, int);
	static computeGeodesicT computeGeodesic;

private:

	HMODULE m_libHandle;
};

Lib::computeGeodesicT Lib::computeGeodesic = NULL;

Lib lib;

void initLibrary() {
}

int main() {
	
	Mesh m("../../meshes/alien.smf");

	std::vector<double> distances(m.vertices().size() * m.vertices().size());

	clock_t t = clock();
	
	Lib::computeGeodesic(&distances[0], &(m.vertices()[0].x), m.faces()[0].vertices, m.vertices().size(), m.faces().size());

	std::cout << double(clock() - t) / CLOCKS_PER_SEC << std::endl;

}
