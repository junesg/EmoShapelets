#include <string>
#include "TimeSeries.hpp"
#include <iostream>
#include <fstream>
#include <sstream>
#include <iterator>
#include <time.h>       //for time
#include <algorithm>    // std::min
#include <stdlib.h>     //aoit
#include <omp.h>        //parallel
#include <algorithm>    //find_if_not
#include "Shapelet.hpp"

using namespace std;
#define SalThresh 0.0
#define verbose 0
#define DEBUG 0


/* Class for TimeSegments */
void TimeSegments:: setValues(string astring) 
{
    istringstream ss(astring);
    bool firstone = true;
    while (ss)
    {   
        string s;
        if (!getline( ss, s, ',' )) break;
        if (firstone)
        {
            Emotion = atoi(s.c_str());
            firstone = false;
        }
        else
        {
            Segment.push_back(atof( s.c_str() ));
        }
    }

    if(verbose) { 
        for (vector<double>::iterator it = Segment.begin(); it !=Segment.end(); it++){
             cout<<" val: "<< *it;
        }
    }   
};


/* creating further segments out */
void TimeSegments:: CreateSegments(int SegLen, int StrideLen)
{
    //make sure the slidingwindowsegments are erased
    slidingWindowSeg.erase(slidingWindowSeg.begin(), slidingWindowSeg.end());

    //create new segments
    int numSec = (int)( (double)(Segment.size() - SegLen + 1)/ double(StrideLen+1))+1 ;
    // cout<<"numSec is "<<numSec<<" SegLen is "<< SegLen <<"Stride is "<< StrideLen<<endl;

    if (numSec <= 0) 
    {
        numSec = 0;
        return ;
    }

    if (numSec == 1 & SegLen > Segment.size() ) 
    {
        cout<< "move on since this segment is too short"<<endl;
        return;
    }
    else {
        int ii;
        for(ii = 0; ii < numSec; ii++)
        {
            int startPt = 2*ii ;
            int endPt = 2*ii+SegLen-1;
            if ( endPt >= Segment.size()) {
                break;
                return;
            }
            else {
                vector<double> temp;
                for ( int jj = startPt; jj<= endPt; jj++){
                    temp.push_back(Segment.at(jj));
                }
                slidingWindowSeg.push_back(temp);
            }
        }
    }
    // DEBUG
    if (DEBUG)
    {
        for(int ii =0; ii < slidingWindowSeg.size(); ii++)
        {
            cout<<"Segment "<<ii<<","<<endl;
            for (int jj=0; jj< slidingWindowSeg.at(ii).size(); jj++)
            {
                cout<<slidingWindowSeg.at(ii).at(jj)<<",";
            }
            cout<<endl;
        }
    }
};



bool isBlankLine(char const* line)
{
    for ( char const* cp = line; *cp; ++cp )
    {
        if ( !isspace(*cp) ) return false;
    }
    return true;
};

bool isBlankLine(std::string const& line)
{
   return isBlankLine(line.c_str());
};


/***********************************************************************************
************************************************************************************
************************************************************************************
Class for TimeSeries****************************************************************
************************************************************************************
************************************************************************************/
void TimeSeries::CreateData(const char* filename) 
{
    string sLine = "";
    ifstream infile;
    infile.open(filename);

    while (!infile.eof())
    {
        getline(infile, sLine);

        if (!sLine.empty() | !isBlankLine(sLine))
        {
            TimeSegments seg;
            seg.setValues(sLine);
            Data.push_back(seg);
        }
    }
    infile.close();
};



void TimeSeries:: GatherAllSegments(int SegLen, int StrideLen)
{
    //make sure to erase all
    AllSegments.erase(AllSegments.begin(), AllSegments.end());
    AllEmotions.erase(AllEmotions.begin(),AllEmotions.end());
    
    cout<<"Data has size "<<Data.size()<<endl<<endl;

    //now loop through data to get segments
    for (int ii=0; ii< Data.size(); ii++){
        TimeSegments seg = Data.at(ii);

        // cout<<" this segment has "<<seg.Segment.size()<<" need seglen " << SegLen<< " and stride " << StrideLen<< endl;

        seg.CreateSegments(SegLen, StrideLen);


        // cout<<" segment "<<ii<< " finish creating segments"<<endl;
        vector< vector <double> > tempSeries = seg.slidingWindowSeg;

        vector<int> tempEmotion;

        if (seg.slidingWindowSeg.size() != 0 ) {
            for(int kk = 0; kk < tempSeries.size(); kk++){
                tempEmotion.push_back(seg.Emotion);
            }

            if (tempSeries.size() < 1)
            {
                cout<<"Error: time series is empty at "<< ii<< " position of data~"<<endl;
            }
            AllSegments.insert(AllSegments.end(),tempSeries.begin(), tempSeries.end());
            AllEmotions.insert(AllEmotions.end(), tempEmotion.begin(), tempEmotion.end());
        }
    }

    if(DEBUG){
        cout<< "length of segments: "<<AllSegments.size()<<" and length of emotions : "<<AllEmotions.size()<<endl;
        for(int ii =0; ii < AllSegments.size(); ii++){
            cout<<"Segment "<<ii<<" with emotion"<<AllEmotions.at(ii)<<endl;
            for (int jj=0; jj< AllSegments.at(ii).size(); jj++){
                cout<<AllSegments.at(ii).at(jj)<<",";
            }
            cout<<endl;
        }
    }

};


void TimeSeries:: PairWiseDist(const char* outFile, const char* segFile, 
                    int segLen, int querylen, float R, bool normalize)
{
    if (AllSegments.size()> 1)
    {
        ofstream myfile;
        myfile.open (outFile);
        ofstream seggFile ; 
        seggFile.open(segFile);
        for (int ii =0; ii< AllSegments.size(); ii++) 
        {
            seggFile<< AllEmotions.at(ii);
            for (int kk = 0; kk< AllSegments.at(ii).size(); kk++){
                seggFile << ","<< AllSegments.at(ii).at(kk);
            }
            seggFile<<endl;

            for (int jj = ii+1; jj< AllSegments.size(); jj++) 
            {
                vector<double> qp = AllSegments.at(ii);
                vector<double> fp = AllSegments.at(jj);

                struct stats stt = FindClosesDTW(  querylen, R, qp, fp , normalize);
                myfile <<  stt.bsf <<",";
                cout<<" "<<ii<< "/"<<AllSegments.size()<<"  and "<<jj<< "/"<<AllSegments.size()<<endl;
                cout<<" sizes are "<<AllSegments.at(ii).size()<<" and "<<AllSegments.at(jj).size()<<endl;
                cout<< " neighbor is "<<endl;
                PrintVector(stt.tz);
            }
        }
        myfile.close();
        seggFile.close();
        return;
    }
    else
    {
        cout<<" Need to initialize the values of AllSegments"<<endl;
        return;
    }
}



vector<vector< double> > dtwAlign(vector<double> refS, vector<double> algS)
{
    //Compute the accurate cost matrix of DTW
    int l1, l2;
    l1 = refS.size();
    l2 = algS.size();

    vector<vector< double> > costM;

    // costM=(double **) malloc((l1+1)*sizeof(double *));
    for(int i=0;i<= l1;i++) 
    {
        vector<double> onevect;

        for (int j=0; j<=l2; j++) 
        {
           onevect.push_back(j);
        }

        costM.push_back(onevect);
    }


    costM.at(0).at(0) = 0;
    for (int i = 1; i <= l1; i++)
        costM.at(i).at(0) = 10000000;
    for (int j =1 ; j<= l2; j++)
        costM.at(0).at(j) = 10000000;

    int i,j;
    for ( i = 1; i<= l1; i++) 
    {
        for ( j=1; j<= l2; j++) 
        {
            double cost = (refS.at(i-1) - algS.at(j-1))*(refS.at(i-1) - algS.at(j-1));
            costM.at(i).at(j) = cost + min(min(costM.at(i-1).at(j),costM.at(i-1).at(j-1)),costM.at(i).at(j-1));
        }
    }
    
    return costM;
}



// This method not only does dtw between ref S and algS, it also returns the vector
// that best matches to refS
vector<vector<double> > DTW_alginment(vector<double> refS, vector<double> algS)
{
    vector< vector <double> > resultS;
    vector<double> noResult;

    for (int i =0; i  < refS.size(); i++) 
    {
        resultS.push_back(noResult);
    }

    int l1, l2;
    l1 = refS.size();
    l2 = algS.size();

    vector<vector< double> > costM = dtwAlign(refS, algS);
    int i = l1+1;
    int j = l2+1;
  
    //now we have costM, get the path back
    i = i-1;
    j = j-1;

    while (i>0 & j > 0) 
    {
        resultS.at(i-1).insert(resultS.at(i-1).begin(),algS[j-1]);
        if (i==0)     
            j = j-1;
        else {
            if (j==0)  
                i = i-1;
            else{
                double score =  min(min(costM.at(i-1).at(j),costM.at(i-1).at(j-1)),costM.at(i).at(j-1));
                if (score == costM.at(i-1).at(j-1)){
                    i = i-1;
                    j = j-1;
                }
                else {
                    if (score == costM.at(i-1).at(j))   
                        i--;
                    else 
                        j--;
                }
            }
        }
    }
    return resultS;
}




/* printing the vector content out */
void TimeSeries::TestPrint(){
    if (Data.size() < 1){
        cout<<" Data has length <1 "<<endl;
    }
    else {
        for (std::vector<TimeSegments>::iterator it = Data.begin() ; it != Data.end(); ++it)
        {
            TimeSegments seg = *it;
            cout<<"Emotion is "<<seg.Emotion<<endl;
            for (std::vector<double>::iterator it2 = seg.Segment.begin(); it2!= seg.Segment.end(); ++it2)
            {
                cout<< *it2<<','<<endl;
            }
            cout<<endl;
            seg.CreateSegments(3, 2);
        }
    }
}


void PrintVector(vector<double> v){
    for (int ii = 0; ii< v.size(); ii++){
        cout<< v.at(ii)<<" , ";
    }
    cout<<endl;
}


void PrintArray(double* v,int m){
    for (int ii = 0; ii< m; ii++){
        cout<< v[ii]<<" , ";
    }
    cout<<endl;
}



void ResultsFromOne(){
    //start from taking in the shapetlets defined in the ReadFromFileGetShapelets files,
    //and then rank  the shapelets, analyze the salience
}





///// main file ////
int main(int argc, char *argv[]){ 
    
    // printing usage
    if (argc < 5)
    {
        cout<< "========================================================"<<endl;
        cout<< "Usage: -.out actorId normalization segLen updateShaeplet"<<endl;
        cout<< "        actorId is the test speaker to be left out "<<endl;
        cout<< "        normalization is boolean to determine whether to noramlize the EmoShapelet's magnitude"<<endl;
        cout<< "        segLen is length of the emoshapelet"<<endl;
        cout<< "        updateShapelet is boolean of determine whether ";
        cout<< "DTWBarycenter averaging should be used for updating"<<endl;
        cout<< "========================================================="<<endl;
        return 0;
    }

    // setting default values
    TimeSeries ts;      // Time series data representation (Emotograms)
    int NumTop = 500;  // estimated maximum number of EmoShapelets to collect
    int MaxSegLen = 40; //qp.size(), maximum segment length to extract from Emotogram to form EmoShapelet candidates
    int queryLen = 5;
    int segLen = MaxSegLen;
    float R = 0.5;
    bool normalize = false;
    bool updateShape = false;

    // get file names
    stringstream fileNameIN, fileName2, fileName3;
    string root = "../Emotograms/winSize0.5s_overlap0.1s/Audio/Series/Corr_TimeSeries_leave";
    ofstream myfile;

    // associate input to variables
    //{'DC','JE','JK','KL'}; the actors are in sequence
    vector<string> allActors;
    const string speakers[] = {"03","08","09","10","11","12","13","14","15","16"};

    for(int i = 0; i < 10; i ++){
        allActors.push_back(speakers[i]);
    }

    int actors = atoi(argv[1]);         // test speaker
    normalize = (bool) atoi(argv[2]);   // whether to normalize the 
    segLen = atoi(argv[3]);             // whether to update the EmoShapelete
    updateShape = atoi(argv[4]);

    // check to make sure that the requested EmoShapelet candidate length is within limit
    if (segLen> MaxSegLen)
    {
        cout<<" The selected segment is larger than max seg "<<MaxSegLen<<" please try again!"<<endl;
        exit(1);
    }
    if (segLen < 5)
    {
        cout<<" The selected segment is smaller than min seg 5 please try again!"<<endl;
        exit(1);
    }
    
    // confirm that actor is the input actor
    cout<<" actor = "<< allActors.at(actors) <<endl;

    int emotions;
    double t00 = clock();

    // using OMP to speed up the process
    omp_set_num_threads(4);
    #pragma omp parallel  private(emotions,ts,fileNameIN, fileName2, fileName3, myfile)
    {
        // which emotion is this OMP thread running       
        emotions = omp_get_thread_num()+1;
        cout<<" current thread "<< omp_get_thread_num() << " out of " << omp_get_num_threads() << endl;
        
        // the files are named as Emotogram_leaveoutJK_train_emotion1.txt
        // now store the shapelets
        fileNameIN << root << allActors.at(actors) <<"train_emotion"<<emotions<<".txt";
        
        // output file names
        if (normalize) 
        {
            if (updateShape)
                fileName3 << "results/winSize0.5s_overlap0.1s/Audio/maxIG/TimesSeries_leave"<< allActors.at(actors) <<"train_noAngle_emotion"<<emotions<<"_allSegmentsNormalizedmaxIG_updated_"<<segLen<<".txt";
            else
                fileName3 << "results/winSize0.5s_overlap0.1s/Audio/maxIG/TimesSeries_leave"<< allActors.at(actors) <<"train_noAngle_emotion"<<emotions<<"_allSegmentsNormalizedmaxIG_noupdate_"<<segLen<<".txt";
        }
        else 
        {
            if (updateShape)
                fileName3 << "results/winSize0.5s_overlap0.1s/Audio/maxIG/TimesSeries_leave"<<  allActors.at(actors)  <<"train_noAngle_emotion"<<emotions<<"_allSegmentsmaxIG_updated"<<segLen<<".txt";
            else
                fileName3 << "results/winSize0.5s_overlap0.1s/Audio/maxIG/TimesSeries_leave"<<  allActors.at(actors)  <<"train_noAngle_emotion"<<emotions<<"_allSegmentsmaxIG_noupdate"<<segLen<<".txt";
        }

        myfile.open ( (const char*)fileName3.str().c_str(), ios::app);
        Shapelet* ListOfTopShapelets[NumTop];
        int currentShapeletCount = 0;

        cout<<" segLen = "<<segLen<<" out of "<<MaxSegLen<<endl;
        R = (float)segLen/(float)5;

        // prepare Data
        cout<<" file in is "<<fileNameIN.str().c_str()<<endl;
        
        ts.CreateData(fileNameIN.str().c_str()); 
        cout<<" Finish creating data ---> "<<endl;
        ts.GatherAllSegments(segLen,2);
        cout<<" Finish gathering segments ---> "<<endl;

        vector<vector< double> > AllData;
        vector<int> AllEmotions1;
        for (int i=0; i< ts.Data.size(); i++)
        {
            if (ts.Data.at(i).Segment.size() > queryLen)
            {
               AllData.push_back(ts.Data.at(i).Segment);
               AllEmotions1.push_back(ts.AllEmotions.at(i));
            }
        }

        
        cout<<" There are "<<ts.AllSegments.size()<<" segments "<<endl;
        cout<<" There are "<<ts.AllEmotions.size()<<" emotions"<<endl;

        for(int segIter = 0; segIter< ts.AllSegments.size(); segIter++)
        {
            bool exists = false;

            cout<<" Currently at segment "<<segIter<<" of "<<ts.AllSegments.size()<<" segments "<<endl;
            double t1 = clock();

            Shapelet* aa = new Shapelet(ts.AllSegments.at(segIter), AllData, AllEmotions1,R,  normalize);

            double t2 = clock();

            aa -> FindThresh(AllData,AllEmotions1);
            
            Shapelet* bb;

            if (updateShape) 
            {
                double t3 = clock();
                bb = aa->UpdateShapelet(AllData,AllEmotions1);
                double t4 = clock();

                if (bb!= NULL) 
                {
                    cout<< " To salience "<< bb-> getSal()<< " thresh "<<bb->getThresh()<<endl;
                    aa->cleanMymemory();
                    delete aa;
                }
                else
                {
                    bb = aa;
                }
            }
            else
            {
                bb = aa;
            }

            //check to see if this has already been stored
            for (int shapeIt = 0; shapeIt < currentShapeletCount; shapeIt ++)
            {
                if (ListOfTopShapelets[shapeIt] -> WithinThresh(bb) )
                {
                    exists = true;
                    cout<<" Current segment is within the neiborhood of semgent  "<<shapeIt<<endl;
                    bb->cleanMymemory();
                    delete bb;
                    break;
                }
            }

            if(!exists & bb->getSal() > SalThresh & currentShapeletCount<= NumTop)
            {
                ListOfTopShapelets[currentShapeletCount] = bb ;
                myfile<<"#####################################"<<endl;
                //first , print out the series
                myfile<< "Time Series "<<segLen<<" length : ";
                for (int sizeit = 0; sizeit < bb->getSize(); sizeit++) {
                    myfile<< (bb->getTS())[sizeit]<<",";
                }
                myfile<<endl;
                //second , print out the threshold and salience
                myfile << "Salience : "<< bb->getSal() <<endl;
                myfile << "Threshold : "<< bb->getThresh() <<endl;
                myfile<<"MyR : "<< bb->getR() <<endl;
                myfile<<"Normalized? : "<< bb->getNormalization() <<endl;
                myfile<<"Occured : "<<bb->  getOccured()<<endl;
                myfile<<"#####################################"<<endl;
                currentShapeletCount ++ ;
            }
        }

        for (int shapeIt =currentShapeletCount-1; shapeIt >=0; shapeIt--)
        {
            Shapelet* kk = ListOfTopShapelets[currentShapeletCount];
            if (kk!= NULL)
            {
                cout<<" kk has content "<< kk<<endl;
                cout<<"test size is "<<ListOfTopShapelets[currentShapeletCount]->getSize()<<endl;
                kk->cleanMymemory();
                ListOfTopShapelets[currentShapeletCount]= NULL;
            }
        }
    }

    // print to filename
    double t01 = clock();
    myfile<<" Total Time : "<<(t01-t00)/CLOCKS_PER_SEC<<" sec for this file"<<endl;
    myfile.close();

}
            



// end of 
