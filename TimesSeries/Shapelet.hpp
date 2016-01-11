#ifndef SHAPLET_H
#define SHAPLET_H



#include <vector> //include for vector 
#include "modUCRDTW.hpp" //for pairwise distance 
#include <stdlib.h> //for standard library
#include <omp.h> //for openmp
#include "myquicksort.hpp"
#include <iostream>
using namespace std;




class Shapelet{
private: 
	int length; //size of the data set (number of emotions, distances or neighbors)
	int mySize ;//size of this time series segment
	float myR; //the window leniency
	bool myNormalize;//whether this is noramlized during comparison
	double* ts; //the series of this shapelet
	double* distance; //min dtw distances to each utterance
	int* emotions; // corresponding emotions of each distance
	double salience ; // the emotion salience of this shapelet
	double threshold ; // the threshod to decide presence
//  	vector< vector<double> > neighbors;   --> deprecated, no more neighbors
	int occured;//the occurance

public:
    Shapelet(double* ts, int size, double sal, double thresh, double occurence, float R, bool normalize);
	Shapelet(vector<double> seg, vector<vector <double> > Data, vector<int> Emotions, float R, bool normalize); //input all time series data --OpenMP to speed up
	void cleanMymemory();
	void FindThresh(vector<vector< double> > Data, vector<int> Emotions);//to find the threshold of the shaplet in the dataset, call only after constructing
	Shapelet* UpdateShapelet(vector<vector<double> > Data, vector<int> Emotions); //update the shapelet based on the closes neighbor distances
	bool WithinThresh(Shapelet* seg); //check to see if one segment is within the threshold of my current shapelet
	double getThresh();
	double getSal();
	int getSize();
	int getOccured();
	double* getTS();
	double* getDist();
	float getR();
	bool getNormalization();
// 	void eraseNeighbors(); --> deprecated , no longer erases
    bool checkReplicate(Shapelet *); //check to see fi these shapelets are actually the same
    vector<vector<double> > FindNeighbor(vector<vector< double> > Data,  vector<int> Emotions);
};


//this quicksorts the distances in a doubel vector, and returs dist-index pair
//use OpenMP to speed up
IndexedDouble*  QuitckSort( vector< double > d);



#endif


//end of file