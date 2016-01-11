function NotNanCol = getNotNanCol()


window_size = 'Inf';
emotions = {'h','a','sa','n','d','f','su'};
speakers = {'DC','JE','JK','KL'};

aud_win_dir = ['../AudioClassification/AudioFeatureExtract/ExtractedData/winSize',window_size,'s'];
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
            save(['AudioDatwin',lower(window_size),'.mat'], 'AllAudioData',...
            'AllAudioLabels', 'AllAudioUtts' );
    end
else
    load(['AudioDatwin',lower(window_size),'.mat']);
end

%% normalize audio data
% now do normalization
% if wwid ~=6
disp('Start data normalization/n');
NotNanCol = 1:size(AllAudioData{1},2);
for speaker_id = 1:length(speakers)
    %leave speaker_id out
    AllAudioData{speaker_id} = (AllAudioData{speaker_id} - ...
        repmat(mean(AllAudioData{speaker_id}),size(AllAudioData{speaker_id},1),1))./ ...
        repmat(std(AllAudioData{speaker_id}), size(AllAudioData{speaker_id},1),1);
    NotNanCol = intersect(NotNanCol, find(~isnan(AllAudioData{speaker_id}(1,:))));
end







end