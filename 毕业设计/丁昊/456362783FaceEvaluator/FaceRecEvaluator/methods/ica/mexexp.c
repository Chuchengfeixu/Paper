#include <math.h>
#include "mex.h"

/* these 2 #define lines help make the later code more readable */
/* Input Arguments */
#define PARAMETER_IN    prhs[0]

/* Output Arguments */
#define RESULT_OUT  plhs[0]

#define LITTLE_ENDIAN  1

static union 
{
  double d;
  struct {
#ifdef LITTLE_ENDIAN
    int j,i;
#else 
    int i,j;
#endif
  } n;
} _eco;

#define EXP_A (1048576/0.69314718055994530942)
#define EXP_C 60801
#define EXP(y) (_eco.n.i = EXP_A*(y) + (1072693248 - EXP_C), _eco.d)

void mexexp(double*y, double*yp, int m) {
  while(m>0) {
    m--;
    yp[m]=EXP(y[m]);
  }
}

void mexFunction( int nlhs, mxArray *plhs[], 
                  int nrhs, const mxArray*prhs[] )
{ 
    double *yp; 
    double *t,*y; 
    unsigned int m,n; 
    
    /* Check for proper number of arguments */    
    if (nrhs != 1) { 
        mexErrMsgTxt("One input argument required."); 
    } else if (nlhs > 1) {
        mexErrMsgTxt("Too many output arguments."); 
    } 
    
    m = mxGetM(PARAMETER_IN); 
    n = mxGetN(PARAMETER_IN);
    
    /* Create a matrix for the return argument */ 
    RESULT_OUT = mxCreateDoubleMatrix(m, n, mxREAL); 
    
    /* Assign pointers to the various parameters */ 
    yp = mxGetPr(RESULT_OUT);    
    y = mxGetPr(PARAMETER_IN);
        
    /* Do the actual computation*/
    mexexp(y,yp,n*n); 
    return;
}
