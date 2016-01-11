#include "Shapelet.hpp"
#include "TimeSeries.hpp"
#include <sstream>
#include <iostream>
#include <fstream>
#include <sstream>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <string.h>
#include <stdlib.h>     /* atof */
#include <math.h> /*log*/


#define verbose 1
using namespace std;
//
//#define MAX_TOKENS_PER_LINE 10000
//#define MAX_CHAR_PER_TOKEN 100
//



vector<Shapelet*> ReadShapelet(string filename, int segLen) {
    ifstream myfile(filename.c_str());
    vector<Shapelet*> thisLength;
    
    
    string line;
    if (myfile.is_open()){
        while (getline(myfile,line)){
            istringstream iss(line);
            if (verbose)
                cout<<" line: "<<line<< " has size "<<line.size()<<endl;
            if ( line.empty()){ //if this stream has no content
                if (verbose)
                    cout<<"empty line"<<endl;
            }
            else{
                double*  ts;
                char chr;
                int length;
                iss.get(chr);
                
                if (chr == '#'){
                    if (verbose) {
                        cout<<" first char is #"<<endl;
                    }
                    //the begining of the file
                    /****** get ts *****/
                    
                    getline(myfile,line); //get the "Time Series 30 length :";
                    
                    if ( strcmp( line.substr(0,11).c_str(), "Time Series")==0 ){//equal
                        
                        string temp;
                        string temp3;
                        string temp2;
                        string com;
                        string longts;
                        
                        
                        std::stringstream ss(line);
                        ss >> temp>>temp3>>length>>temp2>>com>>longts;
                        if(verbose){
                            cout<<" temp is "<< temp<<endl;
                            cout<<" temp3 is "<< temp3<<endl;
                            cout<<" length is "<< length<<endl;
                            cout<<" temp2 is "<< temp2<<endl;
                            cout<<"com is "<<com<<endl;
                            cout<<"Ts is "<<longts<<endl;
                        }
                        
                        ts =(double*)malloc(sizeof(double)*length);
                        if(verbose)
                            cout<<" after replacement "<<longts<<endl;
                        
                        stringstream ss2(longts);
                        string token;
                        int pos = 0;
                        
                        while (getline(ss2,token, ','))
                        {
                            ts[pos] = atof(token.c_str());
                            pos ++;
                        }
                        
                        
                        
                        if (verbose) {
                            cout<<" ts  has length "<<pos<<" and the values are "<<endl;
                            for (int j =0 ; j<pos;j++)
                                cout<<" "<<ts[j];
                            cout<<endl;
                        }
                        
                        
                        
                    }
                    else{
                        cout<<"String problem!"<<endl;
                        return thisLength;
                    }
                    
                    
                    
                    /****** get salience *****/
                    getline(myfile,line); //get the "Time Series 30 length :";
                    std::stringstream ss3(line);
                    string sal;
                    string comma;
                    double salience;
                    ss3>>sal>>comma>>salience;
                    if (verbose) {
                        cout<< sal<<comma<<salience<<endl;
                    }
                    /****** get salience *****/
                    getline(myfile,line);
                    if(verbose)
                        cout<<"Temp ling is "<<line<<endl;
                    
                    std::stringstream ss4(line);
                    string thresh;
                    double theThresh;
                    ss4>>thresh>>comma>>theThresh;
                    if (verbose) {
                        cout<< thresh<<comma<<theThresh<<endl;
                    }
                    
                    /****** get R *****/
                    getline(myfile,line);
                    
                    std::stringstream ss5(line);
                    string RR;
                    float myR;
                    ss5>>RR>>comma>>myR;
                    if (myR == 20){
                        cout<<"myR Should not be 20~"<<endl;
                        return thisLength;
                    }

                    if (verbose) {
                        cout<< RR<<comma<<myR<<endl;
                    }
                    
                    /****** get normalized *****/
                    getline(myfile,line);
                    
                    std::stringstream ss6(line);
                    string NN;
                    bool normalize;
                    ss6>>NN>>comma>>normalize;
                    if (verbose) {
                        cout<< NN<<comma<<normalize;
                    }
                    
                    
                    /****** get normalized *****/
                    getline(myfile,line);
                    
                    std::stringstream ss7(line);
                    string OO;
                    double occurence;
                    ss7>>OO>>comma>>occurence;
                    if (verbose) {
                        cout<< OO<<comma<<occurence;
                    }
                    
                    
                    getline(myfile,line);
                    if(verbose)
                        cout<<segLen<< " is the size we want, "<<length<<" is the size we have"<<endl;
                    if (length==segLen){
                        if(verbose)
                            cout<<"SAME SIZE"<<endl;
                        Shapelet* tempShapet = new Shapelet(ts,length,salience, theThresh, occurence, myR, normalize);
                        thisLength.push_back(tempShapet);
                    }
                    
                }
            }
        }
        
    }
    else{
        cout<<"File "<<filename<<" can not be opened~ "<<endl;
    }
      cout<<" length of the shapelet* is "<<thisLength.size();
    
    myfile.close();
    
    return thisLength;
}







int main( int argc, char* argv[]){
    /******** PART 1: COLLECTION OF SHAPELETS *******/
    //Variables that are fixed:
    int actors = 1;
    int emotions = 1;
    int segLen = 5;
    bool training = 0;
    bool max_or_sum;
    bool updated; 
    // the string of speakers
    const string speakers[] = {"03","08","09","10","11","12","13","14","15","16"};

    
    vector<Shapelet*> TotalSS;

    if (argc < 5){
        cout<<" usage: ./gatherEmoShaeplet.out actorsId emoId segLen training_bool max(0)/sum(1) noupdate(0)/updated(1)"<<endl;
        return 0;
    }
    else{
        actors = atoi(argv[1]);
        emotions = atoi(argv[2]);
        segLen = atoi(argv[3]);
        training = atoi(argv[4]);
        if (argc >= 5 )
            max_or_sum = atoi(argv[5]);
        else
            max_or_sum = 0;
        if(argc > 6 )
            updated = atoi(argv[6]);
        else
            updated = 1;

    }
            

    
    
        stringstream ab;
        int countSS = 0;
    
    
        if (max_or_sum ==0 ) {
            if (updated)
                ab<<"results/winSize0.5s_overlap0.1s/Audio/maxIG/TimesSeries_leave"<<actors<<"train_noAngle_emotion"<<emotions<<"_allSegmentsmaxIG_updated"<< segLen <<".txt";
            else
                ab<<"results/winSize0.5s_overlap0.1s/Audio/maxIG/TimesSeries_leave"<<actors<<"train_noAngle_emotion"<<emotions<<"_allSegmentsmaxIG_noupdate"<< segLen <<".txt";

        }
        else {
            if (updated)
                ab<<"results/winSize0.5s_overlap0.1s/Audio/sumIG/TimesSeries_leave"<<actors<<"train_noAngle_emotion"<<emotions<<"_allSegmentssumIG_updated"<< segLen <<".txt";
            else
                ab<<"results/winSize0.5s_overlap0.1s/Audio/sumIG/TimesSeries_leave"<<actors<<"train_noAngle_emotion"<<emotions<<"_allSegmentssumIG_noupdate"<< segLen <<".txt";

        }
    
            

        if(verbose)
            cout<< " ab is "<<ab.str()<<endl;
            vector<Shapelet*> ss = ReadShapelet(ab.str(), segLen) ;
        //in case there is repetititon, we check for it
        for (int i = 0; i< ss.size(); i++) {
            bool shouldAppend = true;
            for (int j = 0; j< TotalSS.size(); j++) {
                if (ss.at(i)-> checkReplicate(TotalSS.at(j))){
                    //if they are the same
                    shouldAppend = false;
                }
            }
            //in case the shapelet has out of bound magnitude, we check for it
            if(ss.at(i)->getThresh() > 10000){
                shouldAppend = false;
            }
            //if we should append the shapelet.
            if (shouldAppend) {
                TotalSS.push_back(ss.at(i));
                countSS ++;
            }
            else{//if we should not append, delete
                ss.at(i)->cleanMymemory();
                Shapelet* kk = ss.at(i);
                free(kk);
                ss.at(i) =NULL;
            }
        }
        
        if (verbose) {
            cout<<" length of the shapelet* is "<<ss.size();
            for (int i =0; i<ss.size(); i++) {
                cout<<"printing series at "<<i<<":";
                if (ss.at(i)!= NULL ){
                    double* tss = ss.at(i)->getTS();
                    for (int j =0; j< ss.at(i)->getSize(); j++) {
                        cout<< tss[j]<<",";
                    }
                    cout<<endl;
                }
            }
        }
    
    
    
    cout<<"Total.size: "<<TotalSS.size()<<endl;

    int TotoSize = TotalSS.size()-1;

    
    /******** PART 2: Calculate shapelet statistics *******/
    string root = "../Emotograms/winSize0.5s_overlap0.1s/Audio/Series/Corr_TimeSeries_leave";
    stringstream fileNameIN;
    stringstream fileNameOut;
    string type;
    //define the type of shapelets
    if (max_or_sum ==0)
        type = "maxIG";
    else
        type = "sumIG";
    
    if (training) {
        fileNameIN << root<<speakers[actors]<<"train_emotion"<<emotions<<".txt";
        fileNameOut << "results/"<<type<<"/"<<"Shapelets/ShapeletStatsOfleave"<<speakers[actors]<<"train_noAngle_emotion"<<emotions<<"segLength_updated="<<updated<<"_"<<segLen<<".txt";
        cout<<" train File in is "<<fileNameIN.str()<<endl;
        cout<<" train File out is "<<fileNameOut.str()<<endl;

    }
    else{
        fileNameIN << root<<speakers[actors]<<"test_emotion"<<emotions<<".txt";
        fileNameOut << "results/"<<type<<"/Shapelets/ShapeletStatsOfleave"<<speakers[actors]<<"test_noAngle_emotion"<<emotions<<"segLength_updated="<<updated<<"_"<<segLen<<".txt";
        cout<<" test File in is "<<fileNameIN.str()<<endl;
        cout<<" test File out is "<<fileNameOut.str()<<endl;

    }



    TimeSeries ts;    
    //prepare Data
    ts.CreateData(fileNameIN.str().c_str()); //leave 1 out training emitoin1 
    
    if(verbose){ 
        cout<<" Finish creating data ---> "<<endl;
        cout<<" Finish gathering segments ---> "<<endl;
    }
    
    vector<vector< double> > AllData;
    vector<int> AllEmotions;
    for (int i=0; i< ts.Data.size()-1; i++){
        // if (ts.Data.at(i).Segment.size() > segLen){
         cout<< i <<" out of "<<ts.Data.size()<<" we have :"<<ts.Data.at(i).Segment.size()<<endl;
           AllData.push_back(ts.Data.at(i).Segment);
           AllEmotions.push_back(ts.Data.at(i).Emotion);
    }
    
    if (verbose) {
        cout<<" All Data has size "<<AllData.size()<<endl;
        cout<<" All Emotions has size "<<AllEmotions.size()<<endl<<endl<<endl;
    }

    cout<<" All Data has size "<<AllData.size()<<endl;

    
    //Now beging to see shapelets' presence and print it to file
    ofstream myfile;
    myfile.open(fileNameOut.str().c_str());
    cout<<"open myfile"<<endl;

    int EmoCount[4] = {0,0,0,0};
    double salience[TotoSize][4];
    double SumofAllEmo = 0.0;


    int** indexOfShapeletInData = (int**) malloc(sizeof(int*)*AllData.size());
    for (int ki = 0; ki < AllData.size(); ki++)
        indexOfShapeletInData[ki] = (int*)malloc(TotoSize * sizeof(int));


    // cout<<"Total.size: "<<TotoSize<<endl;

    //init co-occurence


    //calculate emotions
    for (int j = 0; j< AllData.size(); j++){
        EmoCount[AllEmotions.at(j)-1] ++;
        // cout<<" Emotions is "<<AllEmotions.at(j)<<endl;
        SumofAllEmo ++;
        //initialize
        for (int jj = 0; jj< TotoSize; jj++){
            indexOfShapeletInData[j][jj] = 0;
            // dataDistToEachShapelet[j][jj] = 0.0;
        }
    }


    //count for co-occurences
    for (int i = 0 ; i < TotoSize; i++) {
        Shapelet* tempS = TotalSS.at(i);
        int Co_occurCount[4];
        for(int j= 0; j < 4; j++){
            Co_occurCount[j] = 0;
        }

        vector<vector<double> > neighbors = tempS->FindNeighbor(AllData, AllEmotions);
        // cout<<"size of neighbors is "<<neighbors.size()<<endl;
        double* distToData = tempS->getDist();
        for (int j = 0; j< neighbors.size(); j++){      
            int ThisEmo = AllEmotions.at(j);
            if (distToData[j] <= tempS->getThresh()){
                Co_occurCount[ThisEmo-1] ++;
                indexOfShapeletInData[j][i] ++;
                // dataDistToEachShapelet[j][i] = distToData[j];
            }
            
        }
        
        if(verbose){
            for(int j= 0; j < 4; j++){
                cout<< Co_occurCount[j]<<","<<endl;
            }
        }
    

        double sumofOccurEmo = 0.0;
        double p_e_given_s[4] = {0,0,0,0};
        for (int emo = 0; emo< 4; emo++){
            sumofOccurEmo+= (double)Co_occurCount[emo];
        }
        double p_s = sumofOccurEmo/AllData.size();
        for (int emo=0; emo<4; emo++){
            //calculate p(e|s)
             p_e_given_s[emo] = (double)Co_occurCount[emo]/sumofOccurEmo;
             //calculate salience scores
             salience[i][emo] = p_e_given_s[emo]*log(p_e_given_s[emo]/((double)EmoCount[emo]/SumofAllEmo));
        }


        /********NOW PRINT THE TIME SERIES **********/
        //print time series
       
            myfile<<"##################################"<<endl;
            myfile<<"Shapelet Index:"<< i <<endl;
            myfile<<"Series:";
            double* tss = tempS->getTS();
            for (int ii = 0 ; ii < tempS->getSize(); ii++){
                myfile<<tss[ii]<<",";
            }
            myfile<<endl;
            //print occurence and salience
            myfile<<"Occurence:";
            for (int emo =0; emo<4; emo++){
                myfile<<Co_occurCount[emo]<<" out of "<<EmoCount[emo]<<",";
            }
            myfile<<endl;
            //print out salience
            myfile<<"Salience:";
            for (int emo =0; emo<4; emo++){
                myfile<<salience[i][emo]<<",";
            }
            myfile<<endl;

            myfile<<"Distance to data"<<endl;
            for (int datiter= 0; datiter< AllData.size(); datiter ++){
                myfile<<distToData[datiter]<<",";
            }
            myfile <<endl;
            myfile<<"##################################"<<endl;     
        

    }



    myfile<<"############NOW PRINT CONTAINING############"<<endl;
    double AccuracyBySalience[4][2];
    //initialize them to zero
    for (int iter = 0; iter<4;iter++){
        for(int iter2 = 0; iter2<2; iter2++){
            AccuracyBySalience[iter][iter2] = 0;
        }
    }

    for (int j = 0; j< AllData.size(); j++){
        myfile<<endl<<"Utt Index:"<<j+1<<" emotion "<<AllEmotions.at(j)<<" contains: "<<endl;
        double salienceUttScore[4];
        for (int jj = 0; jj< TotoSize; jj++){
            
            for (int emo = 0; emo<4; emo++){
                salienceUttScore[emo] = 0;
            }

            if ( indexOfShapeletInData[j][jj]  !=0 ){
                myfile<<jj+1<<",";
                for(int emo=0; emo<4;emo++)
                    salienceUttScore[emo] += salience[jj][emo]; 
            }
        }

        // myfile<<endl<<"Containing distance from each shapelet:"<<endl;
        // for (int jj=0; jj<TotalSS.size(); jj++){
        //     myfile<<dataDistToEachShapelet[j][jj] <<",";
        // }

        myfile<<endl<<"Total Salience scores for happy, angry , sad, neutral are :"<<endl;
        double maxEmo = 0;
        int predEmo = 5;
        for (int emo = 0; emo<4;emo++) {
            myfile<<salienceUttScore[emo]<<",";
            if (salienceUttScore[emo]>maxEmo){
                maxEmo = salienceUttScore[emo];
                predEmo = emo;
            }
        }
        if (predEmo == AllEmotions.at(j)){
            AccuracyBySalience[predEmo-1][0] ++;
            AccuracyBySalience[predEmo-1][1] ++;
        }
        else{
            AccuracyBySalience[predEmo-1][1] ++;
        }
        myfile<<endl<<endl;
    }



      myfile<<"############Acc by salience############"<<endl;

      double totalAcc = 0.0;
      for (int emo = 0; emo<4; emo++){
         totalAcc += AccuracyBySalience[emo][0]/AccuracyBySalience[emo][1];
      }
      myfile<< "Accuracy is "<<AccuracyBySalience[0]<<" out of "<<AccuracyBySalience[1]<<" per class: "<< totalAcc/4 << endl;
    
    for (int ki = 0; ki < AllData.size()-1; ki++)
        free(indexOfShapeletInData[ki]); 

    myfile.close();
    
    //Now begining to see Data's shapelet information and print it to file

    
    return 0;
}




//end of file


