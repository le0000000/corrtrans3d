#include "svd.h"

#include "libs/lapack.h"

void svd(matrix_t& a, matrix_t& u, vector_t& s, matrix_t& vt) {

	initializeLapack();

	int m = a.size1();
	int n = a.size2();

	char jobu, jobvt;
	int lda, ldu, ldvt, lwork, info;
	double *work;

	int minmn, maxmn;

	jobu = 'S'; /* Specifies options for computing U.
		 A: all M columns of U are returned in array U;
		 S: the first min(m,n) columns of U (the left
			singular vectors) are returned in the array U;
		 O: the first min(m,n) columns of U (the left
			singular vectors) are overwritten on the array A;
		 N: no columns of U (no left singular vectors) are
			computed. */

	jobvt = 'A'; /* Specifies options for computing VT.
		  A: all N rows of V**T are returned in the array
			 VT;
		  S: the first min(m,n) rows of V**T (the right
			 singular vectors) are returned in the array VT;
		  O: the first min(m,n) rows of V**T (the right
			 singular vectors) are overwritten on the array A;
		  N: no rows of V**T (no right singular vectors) are
			 computed. */

	lda = m; // The leading dimension of the matrix a.


	ldu = m;

	/* Since A is not a square matrix, we have to make some decisions
	 based on which dimension is shorter. */

	if (m>=n) { minmn = n; maxmn = m; } else { minmn = m; maxmn = n; }

	ldu = m; // Left singular vector matrix
	u.resize(ldu, minmn);
	//u = new double[ldu*minmn];

	ldvt = n; // Right singular vector matrix
	vt.resize(ldvt, n);
	//vt = new double[ldvt*n];

	s.resize(minmn);

	lwork = 5*maxmn; // Set up the work array, larger than needed.
	work = new double[lwork];

	dgesvd(&jobu, &jobvt, &m, &n, &a(0, 0), &lda, &s(0), &u(0, 0),
	  &ldu, &vt(0, 0), &ldvt, work, &lwork, &info);

	delete work;

}
