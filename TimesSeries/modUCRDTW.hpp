#ifndef MODUCRDTW_H
#define MODUCRDTW_H

/** modified UCR_DTW.cpp UCR Suite software to do segment-to-timeSeries
** juneysg@umich.edu
**/

#include <vector>


/// Data structure for sorting the query
typedef struct Index
    {   double value;
        int    index;
    } Index;

/// Data structure (circular array) for finding minimum and maximum for LB_Keogh envolop
struct deque
{   int *dq;
    int size,capacity;
    int f,r;
};

//the stats to be returned from the 
typedef struct stats
	{	
		long long loc; // the location of the query inside the time series
		double bsf; // the best so far dtw distance
        std::vector<double> tz;// the neigbor of this segment
	} stats;


struct stats FindClosesDTW(  int m, float R, std::vector<double> qp,  std::vector<double> fp, bool normalize);


#endif