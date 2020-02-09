#ifndef  SIMULATE              
#define  SIMULATE  
#include "mex.h"
#include "matrix.h"
#include "pHeader.h"
#include <ctime>
//class hNode;
//class aNode;
extern double pomdpL;
extern double pomdpcost;
extern int rounds;
extern int again;
double Simulate(hNode * Tree, int depth);//return reward
double RolloutBelief();
int maxv(hNode *Tree);
int maxvn(hNode *Tree);
//int maxb(mxArry * belief);
#endif 