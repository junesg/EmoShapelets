#ifndef TIMESERIES_H
#define TIMESERIES_H

// #include <stdlib>
#include <vector>
#include <string>
//DEBUG
#include "modUCRDTW.hpp"

using namespace std;


class TimeSegments {
public:
    //variables
    vector<double> Segment;
    int Emotion;
    vector< vector< double > > slidingWindowSeg;
    //functions
    void setValues(string);
    void CreateSegments(int SegLen, int StrideLen);
};


class TimeSeries {
 
public:
   	//functions
    void CreateData(const char*);
    void TestPrint();
    void GatherAllSegments(int SegLen,  int StrideLen);
    void PairWiseDist(const char* outFile, const char* segFile, int segLen, int querylen, float R, bool normalize);
    //variable
    vector<TimeSegments> Data;
    vector< vector<double > > AllSegments;
    vector< int >  AllEmotions;

// private:
	//variable

    
};

void PrintVector(vector<double> v);
void PrintArray(double* v,int m);
vector< vector<double> > DTW_alginment(vector<double> refS, vector<double> algS);
vector< vector<double> > dtwAlign(vector<double> refS, vector<double> algS);


#endif 

