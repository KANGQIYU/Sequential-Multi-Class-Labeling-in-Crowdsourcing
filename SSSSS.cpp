#include "mex.h"
#include "Simulate.h"
#include "pHeader.h"
#include <iostream>
#include <ctime>
#include <chrono>
using namespace std;
//[Used, Declare] = search(rounds, pomdpcost, pomdpL);
//belief is gotten with mexGetVariable
double pomdpL = -20;
double pomdpcost = -1;
int rounds = 8;
int again = 0;
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray * pprhs[2]; //for randob, RolloutBelief and max
    mxArray * pplhs[1]; //for randob, RolloutBelief and max
    mxArray * rhs[4];  //for NextBeliefPOMDP
    mxArray * lhs[1];  //for NextBeliefPOMDP
    mxArray * array_ptr;
    int depth = 1;
//     clock_t begin = clock();
//     clock_t end;
    double reward;
    array_ptr = mexGetVariable("global", "indnrobservation");
    hNode::indnrobservation = mxGetPr(array_ptr);
    array_ptr = mexGetVariable("global", "nrActions");
    hNode::nrActions = (int)((mxGetPr(array_ptr))[0]);
    array_ptr = (mxArray*)prhs[0];
    hNode * Tree = new hNode(array_ptr, 1);
    auto started = std::chrono::high_resolution_clock::now();
    int i = 0;
    while(i<10000)
    {
        int Aindex = maxvn(Tree); //from 0
        Aindex = Aindex<10?5:(Aindex-5);
        double * temp = mxGetPr(Tree->VN);
        
        (Tree->aChildren)[Aindex] = new aNode ((int)((Tree->indnrobservation)[Aindex]));
        
        pprhs[0] = mxCreateDoubleScalar(Aindex+1);
        pprhs[1] = Tree->belief;
//[ ob ] = randob( Aindex, belief )
        mexCallMATLAB(1, pplhs, 2, pprhs, "randob");
        int ob = (int)((mxGetPr(pplhs[0]))[0]);
        mxDestroyArray(pplhs[0]);
        mxDestroyArray(pprhs[0]);
//cannot destory prhs[1]!!!!!
        
        rhs[0] = Tree->belief;
        rhs[1] = mxCreateDoubleScalar(Aindex+1);
        rhs[2] = mxCreateDoubleScalar(ob+1);
        rhs[3] = mxCreateDoubleScalar(depth);
        //[belief1] = NextBeliefPOMDP( belief, a, o, depth)
        mexCallMATLAB(1, lhs, 4, rhs, "NextBeliefPOMDP");
        // mexCallMATLAB(0, NULL, 1, lhs, "disp");
        mxDestroyArray(rhs[1]);mxDestroyArray(rhs[2]);mxDestroyArray(rhs[3]);
        //cannot destory rhs[0]!!!!!
        
        if(depth<=7)
        {
            depth = depth + 1;
        }
        
        else
        {
            depth = 1;
        }
        (((Tree->aChildren)[Aindex])->hChildren)[ob] = new hNode (lhs[0], depth);
        pprhs[0] = lhs[0];
        pprhs[1] = mxCreateDoubleScalar(1);
        //[ reward ] = RolloutBelief( belief, depth)
        mexCallMATLAB(1, pplhs, 2, pprhs, "RolloutBelief");
        reward = mxGetPr(pplhs[0])[0];
        //mexPrintf("Aindex = %d, ob = %d, reward = %f, depth = %d\n", Aindex, ob, reward, depth);
        mxDestroyArray(pplhs[0]);
        mxDestroyArray(pprhs[1]);
        
        
        temp[2*Aindex+1] += 1;
        mxGetPr(Tree->totalN)[0] += 1;
        temp[2*Aindex] = temp[2*Aindex] + (reward - temp[2*Aindex])/temp[2*Aindex+1];
        i+=1;
    }
    auto done = std::chrono::high_resolution_clock::now();
    double a = std::chrono::duration_cast<std::chrono::microseconds>(done-started).count();
    plhs[0] = mxCreateDoubleScalar(3);
}