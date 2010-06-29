#include <algorithm>
#include <iostream>

#include <boost/numeric/ublas/operation.hpp>

#include "libs/arpack.h"

template <typename MAT, typename VECS, typename VALS>
void eigs(VECS& eigVec, VALS& eigVal, const MAT& mat, size_t k, EigsMode mode) {

	namespace ublas = boost::numeric::ublas;

	using namespace std;

	initializeArpack();

	int n = mat.size1();
	int nev = k;
	int ido = 0;
	char bmat[2] = "I";
	char which[3];

	if (mode == EIGS_LARGEST) {
		strcpy(which, "LM");
	} else {
		strcpy(which, "SM");
	}

	double tol = 0.0;
	double *resid;
	resid = new double[n];
	//int ncv = std::min(std::max(nev * 2, 20), n); // 4*nev;
	int ncv = 4*nev;
	if (ncv>n) ncv = n;
	double *v;
	int ldv = n;
	v = new double[ldv*ncv];
	int *iparam;
	iparam = new int[11];
	iparam[0] = 1;
	iparam[2] = 3*n;
	iparam[6] = 1;
	int *ipntr;
	ipntr = new int[11];
	double *workd;
	workd = new double[3*n];
	double *workl;
	workl = new double[ncv*(ncv+8)];
	int lworkl = ncv*(ncv+8);
	int info = 0;
	int rvec = 1;  // Changed from above
	int *select;
	select = new int[ncv];
	double *d;
	d = new double[2*ncv];
	double sigma;
	int ierr;

	ublas::vector<double> in(n);
	ublas::vector<double> out(n);

	int iterno = 0;
	do {
		//cout << endl << "Iter " << iterno << " of dsaupd" << endl;

		/*
		cout << endl << "Calling dsaupd:" << endl;
		cout << "ido = " << ido << endl;
		cout << "bmat = " << bmat << endl;
		cout << "n = " << n << endl;
		cout << "which = " << which << endl;
		cout << "nev = " << nev << endl;
		cout << "tol = " << tol << endl;
		cout << "ncv = " << ncv << endl;
		cout << "ldv = " << ldv << endl;
		cout << "iparam[0,2,6] = " << iparam[0] << ", " << iparam[2] << ", " << iparam[6] << endl;
		cout << "lworkl = " << lworkl << endl;
		cout << "info = " << info << endl;
		*/
		dsaupd(&ido, bmat, &n, which, &nev, &tol, resid, 
			&ncv, v, &ldv, iparam, ipntr, workd, workl,
			&lworkl, &info);
		//ipntr[0] = 1; ipntr[1] = n + 1;
		/*	
		if (iterno++ > 250) {
			ido = 0;
		} else {
			ido = 1;
		}*/

		if ((ido==1)||(ido==-1)) {
			//cout << "Multiplying matrices..." << endl;

			//getchar();

			//cout << "Allocating input vector of size " << n << endl;
			//cout << "Allocating output vector of size " << n << endl;

			//cout << "Copying input..." << endl;
			std::copy(workd+ipntr[0]-1, workd+ipntr[0]-1 + n, in.begin());
			//cout << "Multiplying..." << endl;
			ublas::axpy_prod(mat, in, out, true);
			//cout << "Copying output..." << endl;
			std::copy(out.begin(), out.end(), workd+ipntr[1]-1);

			//cout << "Freeing temporary vectors..." << endl;
			//av(n, workd+ipntr[0]-1, workd+ipntr[1]-1);
		}
		iterno++;
	} while ((ido==1)||(ido==-1));

	if (info<0) {
		std::cout << "Error with dsaupd, info = " << info << "\n";
		std::cout << "Check documentation in dsaupd\n\n";
	} else {
	
		//cout << endl << "Calling dseupd:" << endl;


		//cout << "Calling dseupd" << endl;
		dseupd(&rvec, "All", select, d, v, &ldv, &sigma, bmat,
			&n, which, &nev, &tol, resid, &ncv, v, &ldv,
			iparam, ipntr, workd, workl, &lworkl, &ierr);

		if (ierr!=0) {
			std::cout << "Error with dseupd, info = " << ierr << "\n";
			std::cout << "Check the documentation of dseupd.\n\n";
		} else if (info==1) {
			std::cout << "Maximum number of iterations reached.\n\n";
		} else if (info==3) {
			std::cout << "No shifts could be applied during implicit\n";
			std::cout << "Arnoldi update, try increasing NCV.\n\n";
		}

		//cout << "Copying solutions" << endl;
		for (size_t i = 0; i < k; ++i) {
			eigVal[i] = d[i];
			for (size_t j = 0; j < (size_t)n; ++j) {
				eigVec(j, i) = v[i * n + j];
			}
		}

		//cout << "Freeing memory solutions" << endl;

		//cout << "delete [] resid" << endl;
		delete [] resid;
		//cout << "delete [] v" << endl;
		delete [] v;
		//cout << "delete [] iparam" << endl;
		delete [] iparam;
		//cout << "delete [] ipntr" << endl;
		delete [] ipntr;
		//cout << "delete [] workd" << endl;
		delete [] workd;
		//cout << "delete [] workl" << endl;
		delete [] workl;
		//cout << "delete [] select" << endl;
		delete [] select;
		//cout << "delete [] d" << endl;
		delete [] d;

		//cout << "Exiting eigs..." << endl;
	}

}

