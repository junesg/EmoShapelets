function runMRMRFeatureSelectionAudio(kk,type)
if ~ismember(kk,[0.125,0.25,0.5,1,1.5,2 ,Inf])
    error('Enter a number from 0.125,0.25,0.5,1,1.5,2 or Inf(s)');
end


% audFolder = ['~/google_drive/IEMOCAP_full_release/Code/AudioFeatureExtract/ExtractedData/winSize',num2str(kk),'s/'];

DataType = {'Combined', 'Prototypic', 'Nonprototypic'};

if exist(['mrmrAudioFiles/',DataType{type},'/']) ~=7 
    mkdir(['mrmrAudioFiles/',DataType{type},'/']);
    mkdir(['mrmrAudioFileResults/',DataType{type},'/']);
end
if exist(['mrmrMocapFiles/',DataType{type},'/']) ~=7 
    mkdir(['mrmrMocapFiles/',DataType{type},'/']);
    mkdir(['mrmrMocapFileResults/',DataType{type},'/']);
end



printedTitle = 0;
addpath('../AudioFeatureExtract');% add for the data 
[titleM ,AllData] = getAllAudioData(kk,type); %combined


Actors = {'Ses01F','Ses01M','Ses02F','Ses02M','Ses03F','Ses03M',...
     'Ses04F','Ses04M','Ses05F','Ses05M'};


%print to file
for aa = 1:length(Actors)
    disp('begin writing to mrmr file/n');
    
%     if exist(['mrmrAudioFiles/',DataType{type},'/mrmrFileAudio_winSize',num2str(kk),'leaveout',Actors{aa},'.csv'])~=2
        mrmrfid = fopen(['mrmrAudioFiles/',DataType{type},'/mrmrFileAudio_winSize',num2str(kk),'leaveout',Actors{aa},'.csv'],'w');
        fprintf(mrmrfid, '%s\n',titleM);
        for rr = 1:size(AllData,1)
            if AllData(rr,3) == aa, continue;end % leaving aa out.
            fprintf(mrmrfid, '%f',AllData(rr,1));
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
    system([mrmrSource , '  -i  ' ,['~/google_drive/IEMOCAP_full_release/Code/Evaluations/mrmrAudioFiles/',DataType{type},'/mrmrFileAudio_winSize',num2str(kk),'leaveout',Actors{aa},'.csv'],...
        ' -t 1 -m MID -n 1000 -v 30000 -s 9999 > ', ['~/google_drive/IEMOCAP_full_release/Code/Evaluations/mrmrAudioFileResults/',DataType{type},'/mrmrFileAudio_winSize',num2str(kk),'leaveout',Actors{aa},'results.txt'],' & ' ]);%
    

end




end










%% end of file








%./mrmr -i ~/google_drive/Mturk_temp/SecondRoundEmotion/experiment2/FacialPointsProcess/Baseline/Round2Out/DataFile/winSize90/MRMR_LeaveoutF01.csv -t 1 -m MID -n 100 -v 50000 -s 99999 > ~/google_drive/Mturk_temp/SecondRoundEmotion/experim