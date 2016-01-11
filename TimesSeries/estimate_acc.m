ae_loc = '/home/juneysg/google_drive/Savee/Code/AudioClassification/Emotograms/';
ve_loc = '/home/juneysg/google_drive/Savee/Code/VisualClassification/SVM_Class/Emotograms/';
ave_loc = '/home/juneysg/google_drive/Savee/Code/AudioVisualClassification/SVM_class/Emotograms/';
ave_loc = '/home/juneysg/google_drive/Savee/Code/AudioVisualClassification/SVM_class/Emotograms/win0.5s_overlap0.1s/'
ae_loc = '/home/juneysg/google_drive/Savee/Code/AudioClassification/Emotograms/win0.5s_overlap0.1s/';
ve_loc = '/home/juneysg/google_drive/Savee/Code/VisualClassification/SVM_Class/Emotograms/win0.5s_overlap0.1s/';


loc = ve_loc;
methods = {'max','average','sum'};

Collect_utt4 = {};
Collect_utt7 = {};

for mid = 1:2
wwss = {'0.25','0.125','0.5','1','2'};
emotions = {'h','a','sa','n','d','f','su'};
speakers = {'DC','JE','JK','KL'};
feature_sizes = [50,100,150,200];



Collect_utt4{end+1} = [];
Collect_utt7{end+1} = [];


files = dir(loc);
for fid = 1:length(files)
    
    a_file = files(fid).name;
    disp(['processing ',num2str(fid)]);
	
    if a_file(1) == '.', 
        disp('file is .');
        continue; 
    end
    
	if strfind(a_file, '_test'), 
        disp(' test');
        emo_data = csvread([loc,a_file]);
        emo_l = emo_data(:,1);
        ut = emo_data(:,2);
        act = emo_data(:,3);
        accs = emo_data(:,4:end);

        [utt_acc7, seg_acc7, confusMat7, utt_acc4, seg_acc4, confusMat4 ] = readFromSVMfile([loc,a_file], methods{mid});

        Collect_utt4{end} = [Collect_utt4{end}, utt_acc4,];
        Collect_utt7{end} = [Collect_utt7{end}, utt_acc7];
    end
end



end

clc

for mid =  1:2
    disp('4 class');
    mean(Collect_utt4{mid})
    std(Collect_utt4{mid})
    
    disp('7 class');
    mean(Collect_utt7{mid})
    std(Collect_utt7{mid})
end
