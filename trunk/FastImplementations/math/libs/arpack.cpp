#include <Windows.h>

#include <stdexcept>
#include <iostream>

#include "arpack.h"

dsaupd_t dsaupd = NULL;
dseupd_t dseupd = NULL;

HMODULE arpackModule = NULL;

void initializeArpack() {
	if (!arpackModule) {
		//arpackModule = LoadLibraryA("libmwarpack.dll");
		arpackModule = LoadLibraryA("arpack_win32.dll");
		if (!arpackModule) {
			std::cout << "Failed to load ARPACK DLL" << std::endl;
			throw std::runtime_error("Failed to load ARPACK DLL");
		}

		dsaupd = (dsaupd_t)GetProcAddress(arpackModule, "dsaupd_");
		dseupd = (dseupd_t)GetProcAddress(arpackModule, "dseupd_");

		if (!dsaupd || !dseupd) {
			throw std::runtime_error("Failed to find ARPACK functions");
		}
	}
}
