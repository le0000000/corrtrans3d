#ifndef _MATH_LIB_ARPACK_H_
#define _MATH_LIB_ARPACK_H_

typedef void (*dsaupd_t)(int *ido, char *bmat, int *n, char *which,
						 int *nev, double *tol, double *resid, int *ncv,
						 double *v, int *ldv, int *iparam, int *ipntr,
						 double *workd, double *workl, int *lworkl,
						 int *info);

typedef void (*dseupd_t)(int *rvec, char *All, int *select, double *d,
						 double *z, int *ldz, double *sigma, 
						 char *bmat, int *n, char *which, int *nev,
						 double *tol, double *resid, int *ncv, double *v,
						 int *ldv, int *iparam, int *ipntr, double *workd,
						 double *workl, int *lworkl, int *ierr);

extern dsaupd_t dsaupd;
extern dseupd_t dseupd;

void initializeArpack();

#endif
