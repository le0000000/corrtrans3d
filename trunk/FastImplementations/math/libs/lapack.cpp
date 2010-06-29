#include <Windows.h>

#include <stdexcept>
#include <iostream>

#include "lapack.h"

dgesvd_t dgesvd = NULL;

HMODULE lapackModule = NULL;

void initializeLapack() {
	if (!lapackModule) {
		//lapackModule = LoadLibraryA("libmwlapack.dll");
		lapackModule = LoadLibraryA("lapack_win32.dll");
		if (!lapackModule) {
			std::cout << "Failed to load LAPACK DLL" << std::endl;
			throw std::runtime_error("Failed to load LAPACK DLL");
		}

		dgesvd = (dgesvd_t)GetProcAddress(lapackModule, "dgesvd_");

		if (!dgesvd) {
			throw std::runtime_error("Failed to find LAPACK functions");
		}
	}
}

