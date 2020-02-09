/*=================================================================
 * mexgetarray.c 
 *
 * This example demonstrates how to use mexGetVariable, mexPutVariable, and
 * mexFunctionName. This function takes no input arguments. It counts
 * the number of times mexgetarray.c is called.  It has an internal
 * counter in the MEX-file and a counter in the MATLAB global
 * workspace.  Even if the MEX-file is cleared, it will not lose count
 * of the number of times the MEX-file has been called.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2011 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/
 

#include <stdio.h>
#include <string.h>
#include "mex.h"

static int mex_count = 0;
mxArray * nbe[10000000];
void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{ 
    
    char array_name[40];
    mxArray *array_ptr;
    int status;
    
    

    /* Check for proper number of input and output arguments */    
    if (nrhs !=0) {
        mexErrMsgIdAndTxt( "MATLAB:mexgetarray:minrhs",
                "No input arguments required.");
    } 
    
    
    /* Make copy of MEX-file name, then create variable for MATLAB
       workspace from MEX-file name. */
    strcpy(array_name, mexFunctionName());
    strcat(array_name,"_called");
    
    /* Get variable that keeps count of how many times MEX-file has
       been called from MATLAB global workspace. */
    array_ptr = mexGetVariable("global", array_name);
    mexPrintf("mex_count = %d \n", mex_count);
    /* Check status of MATLAB and MEX-file MEX-file counter */    
    if (array_ptr == NULL ) {
        if( mex_count != 0) {
            mex_count = 0;
            mexPrintf("Variable %s\n", array_name);
            mexErrMsgIdAndTxt( "MATLAB:mexgetarray:invalidGlobalVarState",
                    "Global variable was cleared from the MATLAB \
                    global workspace.\nResetting count.\n");
        }
    	
        /* Since variable does not yet exist in MATLAB workspace,
         * create it and place it in the global workspace. */
        array_ptr=mxCreateDoubleMatrix(1,1,mxREAL);
    }
    
    /* Increment both MATLAB and MEX counters by 1 */
    mxGetPr(array_ptr)[0]+=1;
    mex_count=(int)mxGetPr(array_ptr)[0];
    mexPrintf("%s has been called %i time(s)\n", mexFunctionName(), mex_count);
    
    /* Put variable in MATLAB global workspace */
    status=mexPutVariable("global", array_name, array_ptr);
    
    if (status==1){
        mexPrintf("Variable %s\n", array_name);
        mexErrMsgIdAndTxt( "MATLAB:mexgetarray:errorSettingGlobal",
                "Could not put variable in global workspace.\n");
    }
    /*mxArray * rhs[4];
    mxArray * lhs[1];
    //mxArray * nbe[2];
    rhs[0] = mxCreateDoubleMatrix(64, 1, mxREAL);
    for(int i = 0;i<64;i++)
        mxGetPr(rhs[0])[i] = double(i)/64.0;
    rhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
    mxGetPr(rhs[1])[0] = (double) (2+1);
    rhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
    mxGetPr(rhs[2])[0] = (double) (3+1);
    rhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
    mxGetPr(rhs[3])[0] = (double) (1);
    for(int i = 0;i<100000;i++)
    {
        for(int j = 0;j<64;j++)
        {nbe[(mex_count-1)*100000+i] = mxCreateDoubleMatrix(64, 1, mxREAL);
            mxGetPr(nbe[(mex_count-1)*100000+i])[j] = double(i+j)/64.0;}
    }
    //mexCallMATLAB(0,NULL,1, &nbe[1], "disp");
    /* Destroy array */
    //if(mex_count> 0)
      //  mexPrintf("avvvv =  %f\n", mxGetPr(nbe[4])[0]);
    //for(int i = 0;i<10000000;i++)
    //    nbe[i] = mxCreateDoubleScalar(i);
    //nbe[i] = mxCreateDoubleMatrix(64,1,mxREAL);
    mxDestroyArray(array_ptr);
    /*if (nlhs == 1)
        plhs[0] = mxCreateDoubleMatrix(64, 1, mxREAL);
    else if (nlhs > 1)
         mexErrMsgIdAndTxt("mexFile:tooManyOutputs", "Too many outputs!");
    mxGetPr(plhs[0])[0] = (double) (2+1);*/
  return;
}
