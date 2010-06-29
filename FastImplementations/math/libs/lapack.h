#ifndef _MATH_LIB_LAPACK_H_
#define _MATH_LIB_LAPACK_H_

typedef void (*dgesvd_t)(char *jobu, char *jobvt, int *m, int *n,
						 double *a, int *lda, double *s, double *u,
						 int *ldu, double *vt, int *ldvt, double *work,
						 int *lwork, int *info);

extern dgesvd_t dgesvd;

void initializeLapack();

#endif
