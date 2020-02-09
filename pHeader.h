#ifndef  pHEADER              
#define  pHEADER 
#include "mex.h"
#include "matrix.h"
extern double pomdpL;
extern double pomdpcost;
extern int rounds;

class hNode;
class aNode;

class hNode
{
public:
	hNode(mxArray *nbelief, int depth);
    hNode(mxArray *nbelief);
	~hNode();
//	static int dimension;
    static double * indnrobservation;
    static int nrActions;
    static int numh;
	mxArray * belief;
	mxArray * VN;
    double * VN1;
    mxArray * totalN;
	//double lastaction;
	aNode ** aChildren;
    double declarereward;
    //aNode * Father;
};
class aNode
{
public:
	aNode(int nnrobservation);
    ~aNode();
	hNode ** hChildren;	
    int nrobservation;
};
#endif    