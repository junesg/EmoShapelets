
/* 	quicksort_omp: OpenMP parallel version of quick sort.
 *
 * 	usage: quicksort_omp Nelements [Nthreads]
 *	Nelements = # of integers to sort
 *	Nthreads = # of OMP threads -- MUST BE A POWER OF 2! (Can be 1)
 *		   If unspecified then it uses all available cores
 *
 *	Compile: gcc -O2 quicksort_omp.c -o quicksort_omp -lm -fopenmp -std=c99
 *
 *	Generates Nelements random integers and sorts them in ascending order.
 *	Runs a check at the end to make sure the list is sorted correctly.
 *
 *	Algorithm: The C qsort() function is run on OMP threads to create
 *	a piecewise sorted list, and then those pieces are merged into
 *	a final sorted list.  Note that it requires a temporary array of
 *	(max) size Nelements for the merging.
 *
 *	Benchmarks (YMMV): On an 8-core Xeon, sort time for 100 million
 *	elements is 14.0s on 1 thread, 7.7s on 2, 4.6s on 4, and 3.6s on 8.
 *
 *	Romeel Dave' 5.April.2012
 */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <omp.h>
#include <vector> 
#include <iostream>
#include "myquicksort.hpp"

#define VERBOSE 0
using namespace std;



//compare the index
int compareIndexed(const void * elem1, const void * elem2) {
  IndexedDouble * i1, *i2;
  i1 = (IndexedDouble*)elem1;
  i2 = (IndexedDouble*)elem2;
  return  (i1->value / i2->value);
};



/*
*************************************************************************
*/



/* Merge sorted lists A and B into list A.  A must have dim >= m+n */
void merge(IndexedDouble* A, IndexedDouble* B, int m, int n) //m and n are dimensions
{
    int i=0, j=0, k=0;
    int size = m+n;
    IndexedDouble *C = (IndexedDouble *)malloc(size*sizeof(IndexedDouble));

    while (i < m && j < n) {
        //if the A is better at this stage
        if (A[i].value <= B[j].value) {
            C[k].value= A[i].value;
            C[k].index = A[i].index;
            i++;
        }
        else {
            C[k].value = B[j].value;
            C[k].index = B[j].index;
            j++;
        }
        k++;
    }

    if (i < m) {
        for (int p = i; p < m; p++,k++) {
            C[k].value = A[p].value;
            C[k].index = A[p].index;
        }
    }
    else{ 
        for (int p = j; p < n; p++,k++) {
            C[k].value = B[p].value;
            C[k].index = B[p].index;
        }
    }

    for( i=0; i<size; i++ ) { 
        A[i].value = C[i].value;
        A[i].index = C[i].index;
    }



    // cout<<" is size == k? "<<(size==k)<<endl;

    delete[] C;
    // for( i=0; i<size; i++ ) {
    //     free(C + i);
    // }
}




/* Merges N sorted sub-sections of array a into final, fully sorted array a */
void arraymerge(IndexedDouble *a, int size, int *index, int N)
{
    int i;

    while ( N>1 ) {
        for( i=0; i<N; i++ ) {
            index[i] = (int)i*size/N;
        } 
        index[N]=size;

#pragma omp parallel for private(i)
        for( i=0; i<N; i+=2 ) {
            if( VERBOSE ) {
                fprintf(stderr,"merging %d and %d, index %d and %d (up to %d)\n",i,i+1,index[i],index[i+1],index[i+2]);
            }

            merge(a+index[i],a+index[i+1],index[i+1]-index[i],index[i+2]-index[i+1]);

            if( VERBOSE ) {
                for(int i=0; i<size; i++) fprintf(stderr,"after: %d %f\n",i,a[i].value);
            }
        }
        N /= 2;
    }
}




IndexedDouble *myquicksort(vector<double> distances)
{
    int i;
    
    // set up array to be sorted
    int size = distances.size();//atoi(argv[1]);

    IndexedDouble *a = (IndexedDouble *)malloc(size*sizeof(IndexedDouble));

    for(i=0; i<size; i++) {
        a[i].value = distances.at(i);
        a[i].index = i;
    } 
    
    
    // set up threads
    int threads = omp_get_max_threads();
    // if (threads >= 2 )
    //     threads = 2;

    // cout<<"NUMBER OF THREADS = "<<threads<<endl;
    omp_set_num_threads(threads);
    
    
    // set up index
    int *index = (int *)malloc((threads+1)*sizeof(int));

    for(i=0; i<threads; i++) index[i]=i*size/threads; index[threads]=size;
    

    
    /* Main parallel sort loop */
    double start = omp_get_wtime();
    
#pragma omp parallel for private(i) 
//run for loop
   // i = omp_get_thread_num();
    for(i=0; i<threads; i++) {
        //
        if (omp_get_thread_num() == 0 & VERBOSE) {//
             cout<<"Before comparing"<<endl;
            for (int jjj = index[i]; jjj <index[i+1] ; jjj++) {
                cout<< (a+jjj)->value<<",";
            }
            cout<<endl;
        }

        qsort(a+index[i], index[i+1]-index[i],sizeof(IndexedDouble),compareIndexed);
        
        if (omp_get_thread_num() == 0 & VERBOSE) {//& VERBOSE
            cout<<"After comparing"<<endl;
            for (int jjj = index[i]; jjj <index[i+1] ; jjj++) {
                cout<< (a+jjj)->value<<",";
            }
            cout<<endl;
        }



    }

    // for(int k =0; k < size; k++)
    //     cout<<"val="<< (a+k)->value <<",";
    // cout<<endl;

    double middle = omp_get_wtime();
    
    /* Merge sorted array pieces */
    if( threads>1 ) {
        arraymerge(a,size,index,threads);
    }

    double end = omp_get_wtime();
    
    if(VERBOSE)
         fprintf(stderr,"sort time = %g s, of which %g s is merge time\n",end-start,end-middle);
    
    /* Check the sort -- output should never show "BAD: ..." */
    // for(int i=1; i<size; i++) if( a[i-1].value > a[i].value ) fprintf(stderr,"BAD: %d out of %d %f %f\n",i,size,a[i-1].value,a[i].value);
    free(index);
    return a;
}





//end of file






