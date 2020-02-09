#include "mex.h"
#include "Simulate.h"
#include "pHeader.h"
#include <iostream>
#include <ctime>
using namespace std;
//[Used, Declare] = search(rounds, pomdpcost, pomdpL);
//belief is gotten with mexGetVariable
double pomdpL = 0;
double pomdpcost = 0;
int rounds = 8;
int again = 0;
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{   
//     clock_t begin = clock();
    mxArray * rhs[2];   //for call getDecision
    mxArray * lhs[1];   //for call getDecision
    mxArray *pplhs[2];  //for call max
    mxArray *pprhs[1];  //for call max
    mxArray * newrhs[4]; //for call NextBeliefPOMDP
    mxArray * newlhs[1]; //for call NextBeliefPOMDP
    mxArray * array_ptr;
    hNode * temp;
    //double pomdpL = (mxGetPr(mexGetVariable("global", "pomdpL"))[0]);
    //double pomdpcost = (mxGetPr(mexGetVariable("global", "pomdpcost"))[0]);
    pomdpL = (mxGetPr(prhs[2]))[0];
    pomdpcost = (mxGetPr(prhs[1]))[0];
    rounds = (int)(mxGetPr(prhs[0])[0]);
    int action,decision;
    int depth;
    int Used = -1, Declare = -1;
    array_ptr = mexGetVariable("global", "indnrobservation");
    hNode::indnrobservation = mxGetPr(array_ptr);
    array_ptr = mexGetVariable("global", "nrActions");
    hNode::nrActions = (int)((mxGetPr(array_ptr))[0]);
    array_ptr = mexGetVariable("global", "pomcpruntime");
    int runtime = (int)((mxGetPr(array_ptr))[0]);
    array_ptr = mexGetVariable("caller", "belief");  
//     mexPrintf("belief_1 = %f\n", (mxGetPr(array_ptr))[0]);
//     mexEvalString("pause(.001);");
    
//     mxArray * de = mxCreateDoubleMatrix(2,8,mxREAL);
    if (nrhs != 3)
    {
        mexErrMsgTxt("notcorrect!");
    }
    hNode * Tree = new hNode(array_ptr, 1);
    for(depth = 1; depth <= rounds ;depth++)
    {   hNode::numh = 0;
//         clock_t begin = clock();
//         again = 0;
        for(int i = 0; i< runtime; i++)
            Simulate(Tree, depth);
        
//         mexPrintf("again = %d\n",again);
//         mexEvalString("pause(.001);");
//         clock_t end = clock();
//         double elapsed_secs = double(end - begin)/CLOCKS_PER_SEC;
        
        action = maxv(Tree);
        if(action == (hNode::nrActions))
        {
            break;
        }
        rhs[0] = mxCreateDoubleScalar(action+1);
        rhs[1] = mxCreateDoubleScalar(depth);
        //[decision] = getDecision( Aindex, depth )
        mexCallMATLAB(1, lhs, 2, rhs, "getDecision");
        
        decision = (int)(mxGetPr(lhs[0])[0]); // starts from 1
        //check if next tree is empty
//         mxGetPr(de)[depth*2-2] = action+1;
//         mxGetPr(de)[depth*2-1] = decision+1;
        if(depth < rounds)
        {
            if((Tree->aChildren)[action] == NULL)
            {
                (Tree->aChildren)[action] = new aNode ((int)((Tree->indnrobservation)[action]));
            }
            
            if ((((Tree->aChildren)[action])->hChildren)[decision] == NULL)
            {
                //[belief1] = NextBeliefPOMDP( belief, a, o, depth)
                
                newrhs[0] = Tree->belief;
                newrhs[1] = mxCreateDoubleScalar(action+1);
                newrhs[2] = mxCreateDoubleScalar(decision+1);
                newrhs[3] = mxCreateDoubleScalar(depth);
                
                mexCallMATLAB(1, newlhs, 4, newrhs, "NextBeliefPOMDP");
                (((Tree->aChildren)[action])->hChildren)[decision] = new hNode (newlhs[0], depth+1);
                mxDestroyArray(newrhs[1]);mxDestroyArray(newrhs[2]);mxDestroyArray(newrhs[3]);
                // no need to call mxDestoryArray
            }
            for(int i = 0;i < action;i++)
            {
                delete (Tree->aChildren)[i];
            }
            
            for(int i = action+1;i < (Tree->nrActions);i++)
            {
                delete (Tree->aChildren)[i];
            }
            for(int i = 0;i < decision;i++)
            {
                delete (((Tree->aChildren)[action])->hChildren)[i];
            }
            for(int i = decision+1;i < hNode::indnrobservation[action];i++)
            {
                delete (((Tree->aChildren)[action])->hChildren)[i];
            }
            
            mxDestroyArray(Tree->VN);
            mxDestroyArray(Tree->totalN);
            mxDestroyArray(Tree->belief);
            
            //set Tree = Tree's child
            temp = (((Tree->aChildren)[action])->hChildren)[decision];
            
            delete [] (Tree->aChildren);
            (Tree->aChildren) = NULL;
            Tree = temp;
            //end of delete other branches
        }
        else
        {
            if((Tree->aChildren)[action] == NULL)
            {
                (Tree->aChildren)[action] = new aNode ((int)((Tree->indnrobservation)[action]));
            }
            if ((((Tree->aChildren)[action])->hChildren)[decision] == NULL)
            {
                //[belief1] = NextBeliefPOMDP( belief, a, o, depth)
                
                
                newrhs[0] = Tree->belief;
                newrhs[1] = mxCreateDoubleScalar(action+1);
                newrhs[2] = mxCreateDoubleScalar(decision+1);
                newrhs[3] = mxCreateDoubleScalar(depth);
                
                mexCallMATLAB(1, newlhs, 4, newrhs, "NextBeliefPOMDP");
                (((Tree->aChildren)[action])->hChildren)[decision] = new hNode (newlhs[0]);
                mxDestroyArray(newrhs[1]);mxDestroyArray(newrhs[2]);mxDestroyArray(newrhs[3]);
                //delete temporary variable
                //mxDestroyArray(newrhs[0]);mxDestroyArray(newrhs[1]);mxDestroyArray(newrhs[2]);mxDestroyArray(newrhs[3]);
            }
            for(int i = 0;i < action;i++)
            {
                delete (Tree->aChildren)[i];
            }
            
            for(int i = action+1;i < (Tree->nrActions);i++)
            {
                delete (Tree->aChildren)[i];
            }
            for(int i = 0;i < decision;i++)
            {
                delete (((Tree->aChildren)[action])->hChildren)[i];
            }
            for(int i = decision+1;i < hNode::indnrobservation[action];i++)
            {
                delete (((Tree->aChildren)[action])->hChildren)[i];
            }
            
            mxDestroyArray(Tree->VN);
            mxDestroyArray(Tree->totalN);
            mxDestroyArray(Tree->belief);
            
            //set Tree = Tree's child
            temp = (((Tree->aChildren)[action])->hChildren)[decision];
            
            delete [] (Tree->aChildren);
            (Tree->aChildren) = NULL;
            Tree = temp;
            
            
        }//end of if(depth < rounds)
        
        //delete other children except the chosen one
        
        
        
    }//end of rounds
    
    
    Used = depth-1;
    pprhs[0] = Tree->belief;
//     mexPutVariable("caller", "de", de);
//     mexPutVariable("caller", "ttbelief", pprhs[0]);
    mexCallMATLAB(1, pplhs, 1, pprhs, "getDeclare");
    Declare = (int)(mxGetPr(pplhs[0])[0]); //starts from 1 to dimension
    //delete temporary variables
    mxDestroyArray(pplhs[0]);
    delete Tree;
    //mexPrintf("Used = %d, Declare = %d\n", Used, Declare);
    plhs[0] = mxCreateDoubleScalar(Used);
    plhs[1] = mxCreateDoubleScalar(Declare);
//     clock_t end = clock();
//     double elapsed_secs = double(end - begin)/CLOCKS_PER_SEC;
    //return;
}