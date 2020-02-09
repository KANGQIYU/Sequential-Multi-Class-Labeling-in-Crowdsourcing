#include "pHeader.h"
#include "matrix.h"

double * hNode::indnrobservation = NULL;
int hNode::nrActions = 0;
int hNode::numh = 0;
hNode::hNode(mxArray *nbelief, int depth)
{
    mxArray *prhs[2];
    mxArray *plhs[2];
    numh+=1;
    prhs[0] = nbelief;
    prhs[1] = mxCreateDoubleScalar(depth);
    //[VN, totalN] = initVN (belief, depth)
    mexCallMATLAB(2, plhs, 2, prhs, "initVN");
    VN = plhs[0];
    VN1 = mxGetPr(VN);
    totalN = plhs[1];
    belief = nbelief;
    declarereward = (mxGetPr(VN))[2*nrActions];
//     aChildren = new aNode*[nrActions];
//     for(int i = 0;i<nrActions;i++)
//         aChildren[i]=NULL;
    aChildren = (aNode**)calloc(nrActions,sizeof(aNode*));
        
    //Father = nFather;
}
hNode::hNode(mxArray *nbelief)
{
    mxArray *prhs[1];
    mxArray *plhs[1];
    numh+=1;
    belief = nbelief;
    VN = NULL;
    totalN = NULL;
    prhs[0] = belief;
    mexCallMATLAB(1, plhs, 1, prhs, "max");
    declarereward = (1-mxGetPr(plhs[0])[0])*pomdpL;
    //delete temporary variables
    mxDestroyArray(plhs[0]);
//     aChildren = new aNode*[nrActions];
//     for(int i = 0;i<nrActions;i++)
//         aChildren[i]=NULL;
    aChildren = NULL;
}
hNode::~hNode()
{
    if(aChildren!= NULL)
    {
        for(int i = 0;i<nrActions;i++)
        {
            delete aChildren[i];
        }
        delete [] aChildren;
        aChildren = NULL;
    }
    mxDestroyArray(VN);
    mxDestroyArray(totalN);
    mxDestroyArray(belief);
}


//observation node 
aNode::aNode(int nnrobservation)
{
//      hChildren = new hNode*[nnrobservation];
//      for(int i = 0;i<nnrobservation;i++)
//         hChildren[i]=NULL;
    nrobservation = nnrobservation;
    hChildren = (hNode**)calloc(nnrobservation,sizeof(hNode*));
}
aNode::~aNode()
{
    for(int i = 0;i < nrobservation; i++)
    {
        delete hChildren[i];
    }
    delete [] hChildren;
    hChildren = NULL;
}


/*
double max(const mxArray * nstart, int nlength)
{
    double * start = (double*)mxGetPr(nstart);
    double mmax = start[0];
    for(int i = 1; i < nlength; i++)
    {
        if(mmax<start[i])
        {
            mmax = start[i];
        }
    }
    return mmax;
}
double max(const double * start, int nlength)
{
    double mmax = start[0];
    for(int i = 1; i < nlength; i++)
    {
        if(mmax<start[i])
        {
            mmax = start[i];
        }
    } 
    return mmax;
}*/