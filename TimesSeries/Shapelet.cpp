#include "Shapelet.hpp" //included
#include "myquicksort.hpp"
#include <math.h>       /* log */
#include "TimeSeries.hpp" //for dtwalignment
#include <stdio.h>

#define ratioThresh 10
#define verbose 0

//Destructor of shapelets
void Shapelet::cleanMymemory() {
    if(ts != NULL){
        free(ts);
        ts = NULL;
        // cout<<"ts cleaned "<<endl;
    }
    if (distance != NULL) {
        free(distance);
        distance = NULL;
         // cout<<"distance cleaned "<<endl;
    }
    if (emotions!= NULL) {
        free(emotions);
        emotions = NULL;
         // cout<<"emotions cleaned "<<endl;
    }
};


/*
 * Constructor of shapelet: 1. given the time series OF the shapelets, the salience, threshold, and the
    allowanc (R) steps of comparison band, noramlization and occurence,
 */
Shapelet::Shapelet(double* Ats, int size, double sal, double thresh, double occurence, float R, bool normalize){
    length = 0;
    mySize = size;
    myR = R;
    myNormalize = normalize;
    ts = Ats;
    salience = sal;
    threshold = thresh;
    occured = occurence;
}

/*
 * Constructor of shapelet: 1. based on distance between shapelets and data,
    find max salience, and threshold (the argmax threshold which max the salience)
    and then stores the distance of the segment to each data point,
    This function sets neighbors, distances, emotions, ts, but does not set salience or threshold.
 */
Shapelet::Shapelet(vector<double> seg, vector<vector <double> >  Data, vector<int> Emotions, float R, bool normalize){
    length = Data.size();
    mySize = seg.size();
    myR = R;
    myNormalize = normalize;
    
    // cout<<" Starting Construction of current shaplet ---> "<<endl;
    ts = (double *) malloc(sizeof(double)* seg.size()); //first get the time series from the segments
    // cout<<" ENding Construction of current shaplet1 ---> "<<endl;
    for (int i =0; i < seg.size(); i++){
        ts[i] = seg.at(i);
    }
    // cout<<" ENding Construction of current shaplet2 ---> "<<endl;
    emotions = (int *) malloc(sizeof(int)*length);//copy emotions
    for (int i=0; i< Emotions.size(); i++)
        emotions[i] = Emotions.at(i);
    // cout<<" ENding Construction of current shapelet3 ---> "<<endl;
    
    //this sets the neighbor, and also the distance
    distance = (double *) malloc(sizeof(double)* length);

    salience = -10.0;
    
    // distance=  distance2;
    // cout<<" Finish construction , including distances to all Data time series --->"<<endl;
}


/*
Finding the neighbor of the current time series 
*/
vector<vector<double> > Shapelet::FindNeighbor(vector<vector< double> > Data, vector<int> Emotions) {

    if (verbose)
        cout<< "Entered Shapelet find neighbor!" <<endl;
        
    if (length==0){
        length = Data.size();
        distance = (double *) malloc(sizeof(double)* length);
        emotions = (int *) malloc(sizeof(int)*length);
    }


    //recreate segment vector
    vector<double> seg;
    for(int i = 0; i < mySize; i++) {
        seg.push_back( ts[i] );
    }
    
    //now store the neighbors
    vector<vector<double> > neighbors;
    for (int i = 0; i < Data.size(); i++){
        //for debugging
        if (verbose) { 
            cout<< "enter loop  "<<i<<"/"<<Data.size()<<endl;
            cout<< " seg is  ";
            for (int i =0; i < seg.size(); i++){
                cout<< seg.at(i);
            }
            cout<<endl;
        }
        
        if (Data.at(i).size() > 1 ){

            cout<< " seg:";
            for (int m = 0; m  < seg.size(); m++){
                cout<<seg.at(m)<<"; ";
            }
            cout<<endl;


            cout<< " Data.at(i):";
            for (int m = 0; m  < Data.at(i).size(); m++){
                cout<<Data.at(i).at(m)<<"; ";
            }
            cout<<endl;

            cout<<" seg.size() is "<<seg.size()<<" and myR is "<<myR<<endl;


            struct stats ss  =  FindClosesDTW(seg.size(), myR, seg, Data.at(i), myNormalize);

            cout<<" results: "<< ss.bsf<<endl;

            cout<< " ss.tz:";
            for (int m = 0; m  < ss.tz.size(); m++){
                cout<<ss.tz.at(m)<<"; ";
            }
            cout<<endl;


            neighbors.push_back(ss.tz); //get neighbor
            if (ss.bsf < 0.0000001 | ss.bsf > 100000){
                fprintf(stderr, "bsf: We have huge bsf %f",(float)ss.bsf);
                // exit(0);
            }

            distance[i] = ss.bsf;
            emotions[i] = Emotions.at(i);
        }
        else {
             fprintf(stderr, "Fatal Error #1. We have small than 1 ");

        }
    }

    if(verbose)
        cout<<"finish find neighbors with size "<<neighbors.size()<<endl;
    return neighbors;
}





/*
 This function determines the threshold of which the shapelet should have ( presence/non-presence threshold in terms of dtw distsance)
 The threshold is set to maximize the emotion salience of that shaplet alone
 Threshold is determined based on current
 also initialize the neighbors
 */
void Shapelet::FindThresh(vector< vector< double> > Data,  vector<int> Emotions){
    
    if (length==0){
        length = Data.size();
        distance = (double *) malloc(sizeof(double)* length);
        emotions = (int *) malloc(sizeof(int)*length);
    }
    vector<vector<double> > neigb = FindNeighbor( Data,Emotions);

    // cout<<"Now print distance :";
    // for(int ii = 0; ii < length; ii ++){
    //     cout<< distance[ii]<<",";
    // }
    // cout<<"------"<<endl;



    // cout<<"original salience "<<salience<<endl;

    if(emotions ==NULL  || distance == NULL) {
        cout<<" ERROR: please initialize segment with seg, data, emotion , R and normalization decision"<<endl;
        return;
    }


    if (verbose){
        cout<<"Distance:";
        for (int ii = 0 ; ii< length; ii++){
                cout<<distance[ii]<<",";
        }
        cout<<endl;
    }

    vector<int> UniqueEmo;
    vector<int> CountEmo;
    vector< vector<double> > EmoDistance;
    vector< vector<int> > UtteranceIndex;
    vector< IndexedDouble* > sortedValues;
    
    
    double bestThresh= 1000000000;
    double Bestsalience = 0;
    bool reachend = false;
        
    //Each value in emotion label is corresponding to the neighbors label
    
    bool found = false;
    for (int ii = 0; ii< length; ii++) {
        found = false;
        for (int jj=0; jj< UniqueEmo.size(); jj++){
            if (UniqueEmo.at(jj)== emotions[ii]) {
                CountEmo.at(jj) ++;
                EmoDistance.at(jj).push_back(distance[ii]);
                UtteranceIndex.at(jj).push_back(ii);
                // collectiveDistance.push_back(distances[ii]);
                found = true;
            }
        }
        if (!found) {
            UniqueEmo.push_back(emotions[ii]);
            CountEmo.push_back(1);
            //push back the utterance id
            vector<int> uttInd;
            uttInd.push_back(ii);
            UtteranceIndex.push_back(uttInd);
            //push back the emotion distance
            vector<double> tempDist;
            tempDist.push_back(distance[ii]);
            EmoDistance.push_back(tempDist);
            // collectiveDistance.push_back(distances[ii]);
        }
    }
    
    /*
     * Now we start doing salience sweep
     */
    int numEmo = UniqueEmo.size();
    // cout<<"Started sorting -->"<<endl;
    
    for(int i = 0; i < numEmo; i++) {
        sortedValues.push_back(QuitckSort(EmoDistance.at(i)));
    }
  
    
    // cout<<"start looking for threshold ----->"<<endl;
    //initialize pointrs
    //initialize count(emotion and shapelet)
    int ptrs[numEmo];
    int count_es[numEmo];
    for (int i=0; i < numEmo; i++) {
        ptrs[i] = 0;
        count_es[i] = 0;
    }
    
    //initialize count(shapelet)
    int count_s = 0;
    
    
    //initialize p(emotion)
    double p_e[numEmo];
    double sum_e = 0;
    for (int i=0; i < numEmo; i++){
        sum_e += EmoDistance.at(i).size();
    }
    for (int i=0; i < numEmo; i++){
        p_e[i] = (double)(EmoDistance.at(i).size()) / sum_e ;
         // cout<<" the probability of emotion "<< i+1<< " is " << p_e[i]<<endl;
    }
    
    int cc = 0;
    
    do{
        // cout<<cc++<<" round ... ";
        //look through the smallest distance, see which is smallest among the four sorted arrays
        double minDist = 100000000000;
        for (int i =0; i< numEmo; i++) {
            if (ptrs[i] != EmoDistance.at(i).size()){
                if ((sortedValues.at(i) + ptrs[i])->value <= minDist){
                    minDist = (sortedValues.at(i) + ptrs[i])->value;
                }
            }
        }
        
        for (int i =0; i< numEmo; i++) {
            if (ptrs[i] != EmoDistance.at(i).size()){
                if( (sortedValues.at(i) + ptrs[i])->value == minDist){
                    count_es[i] ++;
                    count_s ++;
                    ptrs[i] ++;
                }
            }
        }
        
        if (verbose){
            for (int i =0; i< numEmo; i++) {
                cout<<ptrs[i]<< "  ";
                cout<< " out of " <<EmoDistance.at(i).size()<<endl;
            }
            cout<<endl;
        }

        //INITIAL ENTROPY
        double curSalience = 0;
        //NOW calculate salience
        for (int i =0; i< numEmo; i++) {
              curSalience += -p_e[i] * log(p_e[i]);
        }

        // cout<<"Original entropy = "<<curSalience<<endl;
        double testVal = 0.0;

        for (int i =0; i< numEmo; i++) {
            double P_e_given_s = (double)(count_es[i]) / (double)(count_s);
            double P_e_given_nots = (double)(p_e[i] - (double)count_es[i]/(double)sum_e)/((double)(sum_e-count_s)/(double)(sum_e));
            double P_s = (double) count_s/(double) sum_e;
            double P_nots = 1-P_s;

            // double P_not_e_given_s = (double)(sum_e - count_es[i])/(double)(count_s);
           
            if (P_e_given_s != 0) {
                curSalience += P_s*P_e_given_s*log(P_e_given_s);
                // testVal += P_s*P_e_given_s*log(P_e_given_s);
            }
            if (P_e_given_nots!= 0) {
               curSalience += P_nots*P_e_given_nots*log(P_e_given_nots);
               // testVal += P_nots*P_e_given_nots*log(P_e_given_nots);
            }
        }
        
        if (verbose)
            cout<<" After splitting at "<< minDist <<" entropy  = "<<-testVal<<endl;

        
         if (curSalience > Bestsalience){
                Bestsalience = curSalience;
                bestThresh = minDist;
                occured = count_s;
                 // cout<<"best thrsh so far "<<bestThresh<<" and  best IG "<< Bestsalience <<endl;
         }

         
        
        reachend = true;
        for (int i=0; i < numEmo; i++) {
            if (ptrs[i] < EmoDistance.at(i).size()-1)
                reachend = false;
        }
    }while(!reachend);
    
    
    //Now we have finished the threshold sweep
    threshold  = bestThresh;
    salience = Bestsalience;
    
    
    //free each of the indexedDouble
    for(int i=0; i< sortedValues.size(); i++){
        free(sortedValues.at(i));
    }
}



//implementing quick sort to sort distances,
// returns vector<int> the index of the sequences
IndexedDouble* QuitckSort( vector< double > d) {
    IndexedDouble *a =  myquicksort(d);
    return a;
}



/*
 * This function takes the neighbors that are above the threshold and update the current curve based on dtw distances
 * uses parallel
 */
Shapelet* Shapelet::UpdateShapelet(vector<vector< double> > Data, vector<int> Emotions){
    //first round, directly use DTW alignment to align this segment and all its neighbors
    vector<vector<double> > neighbors =  FindNeighbor(Data,Emotions);
    //an double array to store my neighbors matching points
    double* myAlginment = (double*)malloc(sizeof(double)*mySize);
    int* alignmentCount = (int*) malloc(sizeof(int)*mySize);
    //make sure the length is correct
    if (Data.size() != length)
        length = Data.size();


    vector<double> myts ; //get my ts into a vector
    for (int i = 0; i< mySize; i++) {
        //initialize myAlignment and alignmentCount to itself
        myAlginment[i] = ts[i];
        alignmentCount[i] = 1;

        //this part is to initialize myts
        if (ts[i] < 0 )
            myts.push_back(0.0);
        else{
            if (ts[i] > 1 )
                myts.push_back(1.0);
            else
                myts.push_back(ts[i]);
        }
    }







    // cout<<endl;
    
    
    for (int i=0; i< length; i++) {
        if (distance[i] <= threshold &  neighbors.at(i).size() > 1){
            vector<vector<double> > oneAlignment =  DTW_alginment( myts, neighbors.at(i));
            for (int j =0; j  < mySize; j++) {
                for (int k = 0; k < oneAlignment.at(j).size(); k++) {
                    myAlginment[j] += oneAlignment.at(j).at(k);
                    alignmentCount[j]  += 1;
                }
            }
        }
    }

    //must double check to make sure every place have at least one match, and the match is not wrong
    for (int i = 0; i < mySize; i++){
        // cout<<i<<", count  = "<<alignmentCount[i]<<",";
        if (myAlginment[i] < 0)
            fprintf(stderr,"the sum of alignment is smaller than 0\n");
        if (alignmentCount[i] <= 0)
            fprintf(stderr,"the count of alignment is smaller than or equal to 0\n");
    }
    cout<<endl;

    
    //now build new 
    vector<double> myts2 ;
    for (int i=0; i< mySize; i++ ){
        // double sumAlg = 0;
        // int Count = 0;
        // for (int j = 0; j < myAlignment.at(i).size(); j++) {
        //     sumAlg += myAlignment.at(i).at(j);
        //     Count ++;
        // }
        myts2.push_back ( myAlginment[i]/(double)(alignmentCount[i]));
        // cout<<"TimeSeries=kflefeklafe"<<ts[i]<<endl;
    }
    
    
    
    vector<int> MyEmotions;
    for (int i = 0; i< length; i++) {
        MyEmotions.push_back(emotions[i]);
    }
    
    
    
    Shapelet* newShape = new Shapelet(myts2, Data, MyEmotions, myR,  myNormalize);

    
    newShape->FindThresh(Data,Emotions);
    
    
    
    if (newShape -> getSal() > salience){
        do {
            // cout<<" Recurse again "<<endl;
            Shapelet* evenNewer = newShape->UpdateShapelet(Data,Emotions);
            if (evenNewer==NULL) {
                break;
                return newShape;
            }
            newShape->cleanMymemory();
            delete newShape;
            newShape = evenNewer;
        }while(true);
        return newShape;
    }
    else{
        // cout<<"Finished"<<endl;
        newShape->cleanMymemory();
        delete newShape;
        Shapelet  *ptr = NULL;
        return  ptr;
    }
    
}



double Shapelet::getThresh(){
    return threshold;
}


double Shapelet::getSal(){
    return salience;
}

int Shapelet::getSize(){
    return mySize;
}

double* Shapelet::getTS(){
    return ts;
}

float Shapelet::getR(){
    return myR;
}

bool Shapelet::getNormalization(){
    return myNormalize;
}

int Shapelet::getOccured(){
    return occured;
}
double* Shapelet::getDist(){
    return distance;
}


// void Shapelet::eraseNeighbors(){
//     neighbors.erase(neighbors.begin(), neighbors.end());
//     // if (emotions != NULL) {
//     //     int* newEmotions = emotions;
//     //     emotions = NULL; free(newEmotions);
//     // }
//     // if (distance != NULL ){
//     //     double* newDistances = distance;
//     //     distance = NULL; free(newDistances);
//     // }
// }


bool Shapelet::checkReplicate(Shapelet* a){
    if(mySize != a->getSize())
        return false;   
    for (int i = 0; i < mySize; i++){
        if (ts[i] != (a->getTS())[i])
            return false;

    }
    //if the size and the time series are the same, we declare replicate
    return true;


}




bool Shapelet::WithinThresh(Shapelet* seg){
     int l1 = seg->getSize();
     int l2 = mySize;
     if (threshold > 10)
        threshold = 10;

    vector<double> segts;
    // cout<<"test seg : ";
    for (int i = 0; i< l1; i++) {
        segts.push_back((seg->getTS())[i]);
        // cout<<(seg->getTS())[i];
    }
    // cout<<endl<<"my seg :";


    vector<double> myts ;
    for (int i = 0; i< l2; i++) {
        myts.push_back(ts[i]);
        // cout<<ts[i];
    }
     // cout<<endl;


    for (int step  = 0; step <= myR; step++) {
        vector<double> shortMyts (myts.begin()+step,myts.end());
        int l22 = l2 - step;
        int l11 = l1;
        vector<vector<double > > M = dtwAlign( segts,shortMyts);
        if (M.at(l11).at(l22) <= threshold/ratioThresh){
            return true;
        }
        // free(M);

        vector<double> shortSegts(segts.begin()+step, segts.end());
        l22 = l2;
        l11 = l1-step;
        vector<vector<double > >  N = dtwAlign( shortSegts,  myts);

        if (N.at(l11).at(l22) <= threshold/ratioThresh){
            return true;
        }
    }
    return false;
}

    // // struct stats ss  =  FindClosesDTW( mySize, myR, segts, myts, myNormalize);

    // if (threshold == 0.0) {
    //     cout<<" ******** ERROR: we do not have threshold set yet ********"<<endl;
    // }
    // else{
    //     if (ss.bsf <= threshold){
    //         return true;
    //     }
    // }



//end of