
% addpath('../AudioFeatureExtract/');
wwss = {'0.25','0.125','0.5','1','2', 'Inf'};%, 'Inf'};
step_size = '0.1';
step_half = false;

for wwid = 3%2:length(wwss)

window_size = wwss{wwid};
emotions = {'h','a','sa','n','d','f','su'};
speakers = {'DC','JE','JK','KL'};
mrmrSource= ['~/google_drive/Mturk_temp/SecondRoundEmotion/',...
        'experiment2/FacialPointsProcess/mrmr_c_src/mrmr'];

if step_half
    aud_win_dir = ['../AudioClassification/AudioFeatureExtract/ExtractedData/winSize',window_size,'s'];
    appendix = '';
else 
    aud_win_dir = ['../AudioClassification/AudioFeatureExtract/ExtractedData/winSize',window_size,'s','_overlap',step_size,'s'];
    appendix = ['_overlap',step_size];
end


if exist(aud_win_dir) ~= 7
    error(['dir ', aud_win_dir,'  does not exist']);
end


aud_files = dir(aud_win_dir); 
AllAudioData = cell(length(speakers),1);
AllAudioLabels = cell(length(speakers),1);
AllAudioUtts = cell(length(speakers),1);


%% 
% Collect data from each speaker
if true%exist(['AudioDatwin',lower(window_size),'.mat'])~=2
    for speaker_id = 1:length(speakers)
            AllAudioUtts{speaker_id} = '';
            for ii=1:length(aud_files)
                disp(['Processing file ', num2str(ii),' for speaker ', num2str(speaker_id),' !'])

                %set the file
                if aud_files(ii).name(1)=='.', continue; end
                if aud_files(ii).name(1:2) ~= speakers{speaker_id}, continue; end

                which_file = aud_files(ii).name;
                comp = strsplit(which_file,'.');

                %get the emotion label
                comp = comp{1};
                emo_id = comp(3:end-2);
                utt = comp(3:end);

                label = 0;
                for emo_j = 1:length(emotions)
                    if emo_id==emotions{emo_j}
                        label = emo_j;
                    end
                end
                if label == 0
                    error('emotion not found');
                end

                %read the files
                fid=fopen([aud_win_dir,'/',which_file],'r');
                titleM=  fgetl(fid);
                titleM = titleM([22:end]);
                fclose(fid);
                if length(csvread([aud_win_dir,'/',which_file],1,2)) ~= 1708
                    disp([aud_win_dir,'/',which_file,' file has not 1708 lines']);
                else
                    AllAudioData{speaker_id} = [AllAudioData{speaker_id}; csvread([aud_win_dir,'/',which_file],1,2)];   
                    AllAudioLabels{speaker_id} = [AllAudioLabels{speaker_id}; repmat(label, size(csvread([aud_win_dir,'/',which_file],1,2),1),1)];
                    for count_ti = 1:size(csvread([aud_win_dir,'/',which_file],1,2),1)
                        AllAudioUtts{speaker_id} = [ AllAudioUtts{speaker_id} , ',' , utt ];
                    end
                end
            end

            save(['AudioDatwin',lower(window_size),appendix,'.mat'], 'AllAudioData',...
            'AllAudioLabels', 'AllAudioUtts' );
    end
else
    load(['AudioDatwin',lower(window_size),appendix,'.mat']);
end

%% normalize audio data
% now do normalization
% if wwid ~=6
disp('Start data normalization/n');
for speaker_id = 1:length(speakers)
    %leave speaker_id out
    AllAudioData{speaker_id} = (AllAudioData{speaker_id} - ...
        repmat(mean(AllAudioData{speaker_id}),size(AllAudioData{speaker_id},1),1))./ ...
        repmat(std(AllAudioData{speaker_id}), size(AllAudioData{speaker_id},1),1);
end

NotNanCol = getNotNanCol(); % get not -nan col from the 


comp = strsplit(titleM,',');
newTitle = [];
for comp_ind = 1:length(NotNanCol)
    newTitle = [newTitle,comp{NotNanCol(comp_ind)},','];
end
newTitle = newTitle(1:end-1);


disp('Finish data normalization/n');

%% load visual data , concat audio and visual data together
if true%exist(['../VisualClassification/VisualDatwin',lower(window_size),'.mat'])~=2
    AudioVisualData = cell(length(speakers),1);
    AudioVisualLabel = cell(length(speakers),1);
    AudioVisualUtts = cell(length(speakers),1);
    % window size already know, get visual data
    facial_file = ['../VisualClassification/FacialExpression_stats_win',lower(window_size),appendix,'s.csv'];
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
        AudioVisualData{visual_act} = [AudioVisualData{visual_act};visual_feat ];
        AudioVisualLabel{visual_act} = [AudioVisualLabel{visual_act}; visual_emotions];
        AudioVisualUtts{visual_act} = [AudioVisualUtts{visual_act} ,',', visual_utts];

    end
    fclose(f);
    %only retain the feature titles 
    visual_title =  visual_title(38:end);

    save(['../VisualClassification/VisualDatwin',lower(window_size),appendix,'.mat'], 'AudioVisualData',...
        'AudioVisualLabel', 'AudioVisualUtts' );
else
    load(['../VisualClassification/VisualDatwin',lower(window_size),appendix,'.mat'])
end



%% now match the data from the two datasets together. 
AllData = cell(length(speakers),1);
AllLabels = cell(length(speakers),1);
AllUtterances = cell(length(speakers),1);

for speaker_id = 1:length(speakers)
    disp(['training speaker', num2str(speaker_id)]);
    
    % prepare vid_utt and aud_utt list 
    aud_utt = strsplit(AllAudioUtts{speaker_id},',');
    vid_utt = strsplit(AudioVisualUtts{speaker_id},',');
    unique_utt=  lower(unique(vid_utt));
    
    for uid = 1:length(unique_utt)
        disp(['collecting the ', num2str(uid),'th unique utterance ']);
        if length(unique_utt{uid})== 0, continue;end
        % get the index of the utterance in audio
        index_utt_aud = [];
        for aud_it = 1:length(aud_utt)
            comp = strsplit(aud_utt{aud_it},'0');
            compare_utt = aud_utt{aud_it};
            if length(comp)==2 && length(comp{1}) >= 1 && length(comp{2}) >= 1
                compare_utt =[ comp{1},comp{2}];
            end
            if strcmp(compare_utt, unique_utt{uid}) == 1
                index_utt_aud =[index_utt_aud,aud_it-1];
            end
        end
       
        % get index of utterance in video
        index_utt_vid = [];
        for vid_it = 1:length(vid_utt)
            if strcmp(lower(vid_utt{vid_it}), unique_utt{uid}) == 1
                index_utt_vid =[index_utt_vid,vid_it-1];
            end
        end  
        
        % this is to make sure the data are of same lengths
        disp(['lengths are aud:',num2str(length(index_utt_aud)), ' and  vid:', num2str(length(index_utt_vid))]);
        if length(index_utt_aud) > length(index_utt_vid)
            index_utt_aud = index_utt_aud(1:length(index_utt_vid));
        else
            index_utt_vid = index_utt_vid(1:length(index_utt_aud));
        end
        
        %assert same label
        assert( sum(AudioVisualLabel{speaker_id}(index_utt_vid,:) - ... 
        	AllAudioLabels{speaker_id}(index_utt_aud,:)) == 0);         
      
        %% now store corresponding info
        row_dat = [ AllAudioData{speaker_id}(index_utt_aud,NotNanCol),AudioVisualData{speaker_id}(index_utt_vid ,:)];
        AllData{speaker_id} = [AllData{speaker_id}; row_dat];
        AllLabels{speaker_id} = [AllLabels{speaker_id}; AllAudioLabels{speaker_id}(index_utt_aud,:)];
        for ut_len = 1:length(index_utt_vid)
            AllUtterances{speaker_id} = [AllUtterances{speaker_id},',',unique_utt{uid}];
        end
        
    end
    
end

save(['TotalAudioVisualData',lower(window_size),appendix,'.mat'])


%%  create mrmr files and select features
%% uncomment to enable writing to mrmr

% now do leave-one-speaker out mrmr selection
% for speaker_id = 1:length(speakers)
%     %leave speaker_id out
%     disp(['printing speaker',num2str(speaker_id)]);
%     CollectData  = [];
%     CollectLabel = [];
%     for sub_speaker = 1:length(speakers)
%         if sub_speaker ~= speaker_id
%             CollectData = [CollectData; AllData{sub_speaker}];
%             CollectLabel = [CollectLabel; AllLabels{sub_speaker}];
%         end
%     end
   
    
%     disp('begin writing to mrmr file/n');
%     ffnn = ['mrmr_files/mrmrFile_winSize',window_size,'leaveout', ...
%         speakers{speaker_id},'.csv'];
%     mrmrfid = fopen(ffnn,'w');
%     % audio visual title
%     fprintf(mrmrfid, 'Emotions,%s\n',[newTitle,',',visual_title]);
%     
%     for rr = 1:size(CollectData,1)
%         fprintf(mrmrfid, '%d', CollectLabel(rr));
%         for comp_ind = 1:length(CollectData(rr,:))
%             fprintf(mrmrfid, ',%f',CollectData(rr,comp_ind));
%         end
%         fprintf(mrmrfid, '\n');
%     end
%     fclose(mrmrfid);
%     


%     system([mrmrSource , ' -i ' ,ffnn,...
%         ' -t 1 -m MID -n 200 -v 30000 -s 9999 > ', ...
%         [ffnn,'_results.txt'],' & ' ]);
    
% end



end






%% end of file









%./mrmr -i ~/google_drive/Mturk_temp/SecondRoundEmotion/experiment2/FacialPointsProcess/Baseline/Round2Out/DataFile/winSize90/MRMR_LeaveoutF01.csv -t 1 -m MID -n 100 -v 50000 -s 99999 > ~/google_drive/Mturk_temp/SecondRoundEmotion/exp