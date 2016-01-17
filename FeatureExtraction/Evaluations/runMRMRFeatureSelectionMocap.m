function runMRMRFeatureSelectionMocap(kk,type,noAngle)
if ~ismember(kk,[0.125,0.25,0.5,1,1.5,2 ,Inf])
    error('Enter a number from 0.125,0.25,0.5,1,1.5,2 or Inf(s)');
end

AnglePresent = {'withAngle', 'noAngle'};
DataTypes = {'Combined','Prototypic','Nonprototypic'};



Actors = {'Ses01F','Ses01M','Ses02F','Ses02M','Ses03F','Ses03M',...
     'Ses04F','Ses04M','Ses05F','Ses05M'};
addpath('../MocapFeatureExtract');% add for the data 

%read in data from file
% whereFile =['/home/juneysg/google_drive/IEMOCAP_full_release/Code/MocapFeatureExtract/winSize',...
%     num2str(1),'s/',DataTypes{type},'/MRMRMocapDatawinSize',num2str(1),'.txt'];
whereFile2 = ['~/google_drive/IEMOCAP_full_release/Code/MocapFeatureExtract/winSize',...
    num2str(kk),'s/',DataTypes{type},'/AllDataMocapDatawinSize',num2str(kk),'_',AnglePresent{noAngle},'.txt'];

if exist(whereFile2)~=2
    error(['file ',whereFile2,' does not exist']);
end

fid=fopen(whereFile2,'r');
titleM=  fgetl(fid);
titleM = titleM([1:9, 28 :end]);
fclose(fid);
% AllData = csvread(whereFile,1,0);
AllData = csvread(whereFile2,1,0);
NotNanCol = find(~isnan(AllData(:,5)));

emoLabels = AllData(NotNanCol,1);
utteranceLabels =  AllData(NotNanCol,2);
actorLabels = AllData(NotNanCol,3);

disp('Finished colleciton data, starts actor normalization\n');

AllData = AllData(NotNanCol,:);

% normalization,
for aa = 1:length(Actors)
    AllData(find(AllData(:,3)==aa),4:end) = (AllData(find(AllData(:,3)==aa),4:end) - ...
        repmat( mean(AllData(find(AllData(:,3)==aa),4:end)),length(find(AllData(:,3)==aa)),1))./ ...
        repmat( std(AllData(find(AllData(:,3)==aa),4:end)),length(find(AllData(:,3)==aa)),1);
end
disp('Finish data normalization/n');
% AllData(find(isnan(AllData))) = zeros(size(find(isnan(AllData))));


ulAll = unique(utteranceLabels);
aaa = histc(utteranceLabels,ulAll);
fidd = fopen('averageLength.txt','w');
fprintf(fidd,'average length is %f frames, std = %f, frame rate 120fps\n',...
    mean(aaa),std(aaa));
fprintf('average length is %f frames, std = %f, frame rate 120fps\n',...
    mean(aaa),std(aaa));
fclose(fidd);

%print to file
for aa = 1:length(Actors)
    disp('begin writing to mrmr file/n');
%     if exist(['mrmrMocapFiles/',DataTypes{type},'/mrmrFileMocap_winSize',num2str(kk),'leaveout',Actors{aa},'.csv'])~=2
        ffnn = ['mrmrMocapFiles/',DataTypes{type},'/mrmrFileMocap_winSize',num2str(kk),'leaveout',Actors{aa},'_',AnglePresent{noAngle},'.csv'];
        mrmrfid = fopen(ffnn,'w');
        fprintf(mrmrfid, '%s\n',titleM);
        for rr = 1:size(AllData,1)
            if AllData(rr,3) == aa, continue;end % leaving aa out.
            fprintf(mrmrfid, '%d',AllData(rr,1));
            for coll = 4:size(AllData,2)
                fprintf(mrmrfid, ',%f',AllData(rr,coll));
            end
            fprintf(mrmrfid, '\n');
        end
        fclose(mrmrfid);
%     end
    
    aa
    disp('finished writing to mrmr file/n');
   
    mrmrSource= ['~/google_drive/Mturk_temp/SecondRoundEmotion/',...
        'experiment2/FacialPointsProcess/mrmr_c_src/mrmr'];
    % disp([mrmrSource , ' -i ' ,['~/google_drive/IEMOCAP_full_release/Code/Evaluations/mrmrAudioFiles/mrmrFileAudio_winSize',num2str(kk),'leaveout',Actors{aa},'.csv'],...
        % ' -t 1 -m MID -n 200 -v 30000 -s 9999 > ', ['~/google_drive/IEMOCAP_full_release/Code/Evaluations/mrmrAudioFileResults/mrmrFileAudio_winSize',num2str(kk),'leaveout',Actors{aa},'results.txt'],' & ' ]);
    system([mrmrSource , ' -i ' ,['~/google_drive/IEMOCAP_full_release/Code/Evaluations/mrmrMocapFiles/',DataTypes{type},'/mrmrFileMocap_winSize',num2str(kk),'leaveout',Actors{aa},'_',AnglePresent{noAngle},'.csv'],...
        ' -t 1 -m MID -n 200 -v 30000 -s 9999 > ', ['~/google_drive/IEMOCAP_full_release/Code/Evaluations/mrmrMocapFileResults/',DataTypes{type},'/mrmrFileMocap_winSize',num2str(kk),'leaveout',Actors{aa},'_',AnglePresent{noAngle},'results.txt'],' & ' ]);%
    

end




end










%% end of file









%./mrmr -i ~/google_drive/Mturk_temp/SecondRoundEmotion/experiment2/FacialPointsProcess/Baseline/Round2Out/DataFile/winSize90/MRMR_LeaveoutF01.csv -t 1 -m MID -n 100 -v 50000 -s 99999 > ~/google_drive/Mturk_temp/SecondRoundEmotion/exper