#include "Simulate.h"
#include "pHeader.h"
#include "mex.h"
#include <iostream>
#include <ctime>
#include <chrono>
int maxv(hNode *Tree)
{
    mxArray *prhs[1];
    prhs[0] = Tree->VN;
    mxArray *plhs[1];
    mexCallMATLAB(1, plhs, 1, prhs, "maxV");
    int index = (int)(mxGetPr(plhs[0])[0]);  //in C++, starts from 0
    mxDestroyArray(plhs[0]);
    return index;
}
int maxvn(hNode *Tree)
{
    mxArray * prhs[2];
    mxArray * plhs[1];
    prhs[0] = Tree->VN;
    prhs[1] = Tree->totalN; 
    mexCallMATLAB(1, plhs, 2, prhs, "maxVN");
    int index = (int)mxGetPr(plhs[0])[0];
    mxDestroyArray(plhs[0]);
    return index;
}

double Simulate(hNode * Tree, int depth)//return reward
{
    //Current Tree is not empty.
    

    mxArray * prhs[2]; //for randob, RolloutBelief and max
    mxArray * plhs[1]; //for randob, RolloutBelief and max
    mxArray * rhs[4];  //for NextBeliefPOMDP
    mxArray * lhs[1];  //for NextBeliefPOMDP
//     clock_t begin = clock();
//     clock_t end;
    double reward;
//     double elapsed_secs;
    if(depth<=rounds)
    {   
        int Aindex = maxvn(Tree); //from 0
        double * temp = mxGetPr(Tree->VN);
        if(Aindex < (Tree->nrActions))
        {
           
            if((Tree->aChildren)[Aindex] == NULL)
            {
                (Tree->aChildren)[Aindex] = new aNode ((int)((Tree->indnrobservation)[Aindex]));
            }
            prhs[0] = mxCreateDoubleScalar(Aindex+1);
            prhs[1] = Tree->belief;
            //[ ob ] = randob( Aindex, belief )
            mexCallMATLAB(1, plhs, 2, prhs, "randob");
            int ob = (int)((mxGetPr(plhs[0]))[0]);
            mxDestroyArray(plhs[0]);
            mxDestroyArray(prhs[0]);
            //cannot destory prhs[1]!!!!!
             auto started = std::chrono::high_resolution_clock::now();
            if ((Tree->aChildren)[Aindex]->hChildren[ob] == NULL)
            {
                rhs[0] = Tree->belief;
                rhs[1] = mxCreateDoubleScalar(Aindex+1);
                rhs[2] = mxCreateDoubleScalar(ob+1);
                rhs[3] = mxCreateDoubleScalar(depth);
                //[belief1] = NextBeliefPOMDP( belief, a, o, depth)
                mexCallMATLAB(1, lhs, 4, rhs, "NextBeliefPOMDP");
               // mexCallMATLAB(0, NULL, 1, lhs, "disp");
                mxDestroyArray(rhs[1]);mxDestroyArray(rhs[2]);mxDestroyArray(rhs[3]);
                //cannot destory rhs[0]!!!!!
                
                if(depth<rounds)
                {
                    (((Tree->aChildren)[Aindex])->hChildren)[ob] = new hNode (lhs[0], depth+1);    
                }
                
                else
                {
                    (((Tree->aChildren)[Aindex])->hChildren)[ob] = new hNode (lhs[0]);  
                }
                
                                 auto done = std::chrono::high_resolution_clock::now();
    double a = std::chrono::duration_cast<std::chrono::microseconds>(done-started).count();
                prhs[0] = lhs[0];
                prhs[1] = mxCreateDoubleScalar(depth+1);
                //[ reward ] = RolloutBelief( belief, depth)
                mexCallMATLAB(1, plhs, 2, prhs, "RolloutBelief");
                reward = mxGetPr(plhs[0])[0];
                //mexPrintf("Aindex = %d, ob = %d, reward = %f, depth = %d\n", Aindex, ob, reward, depth);
                mxDestroyArray(plhs[0]);
                mxDestroyArray(prhs[1]);
                //cannot destory prhs[0]!!!!!
   
            }
            else
            {
                //mexPrintf("next level");;
                reward = pomdpcost + Simulate((Tree->aChildren)[Aindex]->hChildren[ob], depth+1);
                again += 1;
            }
            
            
            temp[2*Aindex+1] += 1;
            mxGetPr(Tree->totalN)[0] += 1;
            temp[2*Aindex] = temp[2*Aindex] + (reward - temp[2*Aindex])/temp[2*Aindex+1];
            
        } // "if(Aindex < (Tree->nrActions))"
        else
        {
            reward  = temp[2*Aindex];
            temp[2*Aindex+1] += 1;
            (mxGetPr(Tree->totalN))[0] += 1;
        }// end of "if(Aindex < (Tree->nrActions-1))"
        
    }// "if(depth<=rounds)"
    else
    {
        reward = Tree->declarereward;
    }
//     end = clock();
//     elapsed_secs = double(end - begin)/CLOCKS_PER_SEC;
//     auto done = std::chrono::high_resolution_clock::now();
//     double a = std::chrono::duration_cast<std::chrono::microseconds>(done-started).count();
    return reward;
}