/* system example : DIR */
#include <stdio.h>      /* printf */
#include <stdlib.h>     /* system, NULL, EXIT_FAILURE */
#include <vector>
#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
#include <string.h>
#include <string>
#include <algorithm>


using namespace std;

int main() {
	std:: vector<string> filenames;
	filenames.push_back("SaveeAudioSummary.csv");
// 	filenames.push_back("ChinesePell.csv");
// 	filenames.push_back("EmoDB.csv");
// 	filenames.push_back("IEMOCAP.csv");

	std:: vector<string> storageDir;
	storageDir.push_back("/home/juneysg/google_drive/Savee/Code/AudioFeatureExtract/ExtractedData/winSize1s/");
// 	storageDir.push_back("/home/juneysg/Documents/EECS545project/opensmile-2.0-rc1/DataSets/MachineLearningProject/ExtractionResults/1window0.5step/ChinesePell/");
// 	storageDir.push_back("/home/juneysg/Documents/EECS545project/opensmile-2.0-rc1/DataSets/MachineLearningProject/ExtractionResults/1window0.5step/EmoDB/");
// 	storageDir.push_back("/home/juneysg/Documents/EECS545project/opensmile-2.0-rc1/DataSets/MachineLearningProject/ExtractionResults/1window0.5step/IEMOCAP/");


	//loop through the files
	for (int index = 0 ; index < filenames.size(); index ++) {
	
		string path_to_file = "/home/juneysg/google_drive/Savee/Code/AudioFeatureExtract/";
		string path_to_se = "/home/juneysg/Documents/EECS545project/opensmile-2.0-rc1/opensmile/";
		string path_config = "/home/juneysg/google_drive/Savee/Code/AudioFeatureExtract/LocalFeature_Juneysg_csv.conf";
		const char* filepath = path_to_file.append(filenames.at(index)).c_str();

		vector<string> results;
		ifstream myfile (filepath, std::ifstream::in);
		string line;
		
		//first, get rid of the title line, 
		//then locate the path at location
		if (myfile.is_open()) {
			getline(myfile, line); //this is the first line
			getline(myfile,line);  //second line
            cout<<"second line is "<<line<<endl;
			stringstream ss;	
			ss<<line;	

			int count = 0;
			int location;

			while (ss.good()){
				string substr;
				getline(ss, substr, ',');
				//cout<<":"<<substr<<":"<<endl;
				//cout<<"next"<<endl;
                substr.erase(remove(substr.begin(), substr.end(),' '),substr.end());
				if (substr.compare("Path") == 0) {
					location = count;
					//cout<<"should be == path: ";
					cout<<"localt is "<<location<<endl;
				}
				count ++;
			} 
			
//loop thorugh each line of the csv file to find the path, the file name and relevant ino
			while (getline(myfile, line)){
				//getline(myfile,line);
				stringstream ss2;  //used for dilimiting
				ss2 << line;	
				int count2 = 0;
				std::string file_loc; //use to store the file name
				vector<string> results; //stores relevant information
				while (ss2.good()){
					std::string SubString;
					getline(ss2, SubString, ',');
					if (count2 == location) {
// 						if (index == 1)
// 							file_loc = SubString.substr(0,SubString.size()-1);
// 						else
							file_loc = SubString;
                            //cout<<" subString is "<<SubString<<endl;
					}
					count2++;
					results.push_back(SubString);
                    
				}
                
                
                
                    cout<<"input file is "<<file_loc<<endl;
					//process the file, create the outupt, 
					//	puts the rest of the information into the output file	
					string astring = results.at(0);
					//get rid of white spaces in file name
					astring.erase(remove(astring.begin(), astring.end(),' '),astring.end());
					string storage_filename =  storageDir.at(index)+ astring+".csv";
			
					//concat commands for the terminal to run
					string command1 = "cd "+ path_to_se+" && ./SMILExtract -C " ;
					string command2 = path_config+ " -I " + file_loc;
					string command3 = " -O "+ storage_filename;
					string all_command = command1+command2+command3;


					if (system(NULL)) 
						system((const char*)all_command.c_str());
					else {
						perror("can not execute");
					}
				//move on to next file 
			}
			myfile.close();
		}
		else cout<<"Unable to open file " <<filepath<<endl;
	}


	return 0;
}


//end of file