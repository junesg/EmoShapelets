
wwss = {'0.125','0.5','1','2','Inf'}; %0.25

for wwid = 1:length(wwss)-1
window_size = wwss{wwid};
emotions = {'h','a','sa','n','d','f','su'};
speakers = {'DC','JE','JK','KL'};
mrmrSource= ['~/google_drive/Mturk_temp/SecondRoundEmotion/',...
        'experiment2/FacialPointsProcess/mrmr_c_src/mrmr'];


%% 
% Collect data from each speaker
if exist(['VisualDatwin',lower(window_size),'.mat'])~=2
    AllVisualData = cell(length(speakers),1);
    AllVisualLabels = cell(length(speakers),1);
    AllVisualUtterancess = cell(length(speakers),1);
    % window size already know, get visual data
    facial_file = ['FacialExpression_stats_win',lower(window_size),'.csv'];
    if exist(facial_file)~=2, error('Facial File does not exist'); end
    % get visual title
    f = fopen(facial_file,'r');
    visual_title  = fgetl(f);
    while ~feof(f)
        % get visual data
        tline = fgetl(f);
        comp = strsplit(tline, ',');
        visual_emotions = str2num(comp{1});
        visual_utts = comp{2};
        visual_act = str2num(comp{3});
        visual_feat = str2num(comp{5});
        for ii = 6:length(comp)
            visual_feat = [visual_feat ,str2num(comp{ii})];
        end
        % add data into the collection
        AllVisualData{visual_act} = [AllVisualData{visual_act};visual_feat ];
        AllVisualLabels{visual_act} = [AllVisualLabels{visual_act}; visual_emotions];
        AllVisualUtterancess{visual_act} = [AllVisualUtterancess{visual_act} ,',', visual_utts];

    end
    fclose(f);
    %only retain the feature titles 
    visual_title =  visual_title(38:end);

    save(['VisualDatwin',lower(window_size),'.mat'], 'AllVisualData',...
        'AllVisualLabels', 'AllVisualUtterancess' );
else
    load(['VisualDatwin',lower(window_size),'.mat'])
end



%% 
% now do leave-one-speaker out mrmr selection
for speaker_id = 1:length(speakers)
    %leave speaker_id out
    CollectData  = [];
    CollectLabel = [];
    for sub_speaker = 1:length(speakers)
        if sub_speaker ~= speaker_id
            CollectData = [CollectData; AllVisualData{sub_speaker}];
            CollectLabel = [CollectLabel; AllVisualLabels{sub_speaker}];
        end
    end
    
    
    disp('begin writing to mrmr file/n');
    ffnn = ['mrmrFiles/mrmrFile_winSize',window_size,'leaveout', ...
        speakers{speaker_id},'.csv'];
    mrmrfid = fopen(ffnn,'w');
    fprintf(mrmrfid, 'Emotions,%s\n',visual_title);
    
    if exist(ffnn) ~=2
        for rr = 1:size(CollectData,1)
            fprintf(mrmrfid, '%d', CollectLabel(rr));
            for comp_ind = 1:size(CollectData,2)
                fprintf(mrmrfid, ',%f',CollectData(rr,comp_ind));
            end
            fprintf(mrmrfid, '\n');
        end
        fclose(mrmrfid);
        

      
        system([mrmrSource , ' -i ' ,ffnn,...
            ' -t 1 -m MID -n 200 -v 30000 -s 9999 > ', ...
            [ffnn,'_results.txt'],' & ' ]);
    
    end
end



end






%% end of file









%./mrmr -i ~/google_drive/Mturk_temp/SecondRoundEmotion/experiment2/FacialPointsProcess/Baseline/Round2Out/DataFile/winSize90/MRMR_LeaveoutF01.csv -t 1 -m MID -n 100 -v 50000 -s 99999 > ~/google_drive/Mturk_temp/SecondRoundEmotion/exper