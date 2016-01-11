#ifndef MYQUICKSORT_H
#define MYQUICKSORT_H

#include <vector>
#include <stdlib.h>
using namespace std;

//define own structure
typedef struct IndexedDouble {
  	double value;
  	int index;
} IndexedDouble;


//initialize a array of the 
int compareIndexed(const void * elem1, const void * elem2) ;
void merge(IndexedDouble* A, IndexedDouble* B, int m, int n);
void arraymerge(IndexedDouble *a, int size, IndexedDouble *index, int N);
IndexedDouble* myquicksort(vector<double> distances);

// int compareIndexed(const void * elem1, const void * elem2) ;
// void merge(int A[], int B[], int m, int n);
// void arraymerge(int *a, int size, int *index, int N);
// vector <int>  myquicksort(vector<double> *distances);

// typedef struct tempStruct {
//   vector< double> distances;
//   vector <int> index; 
// } tempStruct;

#endif