
wwss = {'0.25'};
wwss = {'0.25','0.5','1.0','0.125'}; %0.25
emotions = {'h','a','sa','n','d','f','su'};
speakers = {'DC','JE','JK','KL'};
step_sizes = {'0.1','0.1','0.1','0.1'};
step_half = false;

for wwid = 2%:length(wwss)
    window_size = wwss{wwid};
    step_size = step_sizes{wwid};

    disp(['wwid is ',num2str(wwid)]);
    %% first get the visual data
    if true%exist(['VisualDatwin',lower(window_size),'.mat'])~=2
        AllVisualData = cell(length(speakers),1);
        AllVisualLabels = cell(length(speakers),1);
        AllVisualUtterancess = cell(length(speakers),1);
        % window size already know, get visual data
        if step_half
            facial_file = ['FacialExpression_stats_win',lower(window_size),'.csv'];
        else
            facial_file = ['FacialExpression_stats_win',lower(window_size),'_overlap',step_size,'s.csv'];
        end

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

        if step_half
            save(['VisualDatwin',lower(window_size),'.mat'], 'AllVisualData',...
                'AllVisualLabels', 'AllVisualUtterancess','visual_title' );
        else
            save(['VisualDatwin',lower(window_size),'_overlap',step_size,'.mat'], 'AllVisualData',...
                'AllVisualLabels', 'AllVisualUtterancess','visual_title' );
        end
    else
        if step_half
            load(['VisualDatwin',lower(window_size),'.mat'])
        else
            load(['VisualDatwin',lower(window_size),'_overlap',step_size,'.mat']);
        end
    end




    
    %%
    % now do leave-one-speaker out feature generation 
    for speaker_id = 1:length(speakers)


        if step_half
            appendex = '';
        else
            appendex = ['_overlap',step_size];
        end

        %leave speaker_id out
        ffnn = ['featureFiles/featureFile_winSize',window_size,'leaveout', ...
            speakers{speaker_id},appendex,'visual.csv'];
        ffnn2 = ['featureFiles/featureFile_winSize',window_size,'leaveout', ...
            speakers{speaker_id},appendex,'visual_test.csv'];
        
        % first read from mrmr
        % mrmrffnn = ['mrmrFiles/mrmrFile_winSize',window_size,'leaveout', ...
        %     speakers{speaker_id},'.csv_results.txt'];

        mrmrffnn = ['mrmrFiles/mrmrFile_winSize','Inf','leaveout', ...
            speakers{speaker_id},'.csv_results.txt'];
        
        [feat_ind, scores] = ReadFromMRMRFile(mrmrffnn);
            
        % collect training dataset
        CollectData  = [];
        CollectLabel = [];
        CollectUtt = [];
        CollectSPeaker= [];
        for sub_speaker = 1:length(speakers)
            if sub_speaker ~= speaker_id
                CollectData = [CollectData; AllVisualData{sub_speaker}(:,feat_ind)];
                CollectLabel = [CollectLabel; AllVisualLabels{sub_speaker}];
                utt_string = AllVisualUtterancess{sub_speaker}(2:end);
                CollectUtt = [CollectUtt,',',utt_string];
                CollectSPeaker = [CollectSPeaker; repmat(sub_speaker, size(AllVisualData{sub_speaker},1),1)];
            end
        end
        CollectUtt = CollectUtt(2:end); %adjust for the ','
        Utt_comp = strsplit(CollectUtt,',');
        u_utt = unique(Utt_comp);

        % collect testing dataset
        TestCollectData  = [];
        TestCollectLabel = [];
        TestCollectUtt = [];
        TestCollectSPeaker= [];
        sub_speaker = speaker_id;
        TestCollectData = [AllVisualData{sub_speaker}(:,feat_ind)];
        TestCollectLabel = [AllVisualLabels{sub_speaker}];
        Testutt_string = AllVisualUtterancess{sub_speaker}(2:end);
        TestCollectUtt = [',',Testutt_string];
        TestCollectSPeaker = [ repmat(sub_speaker, size(AllVisualData{sub_speaker},1),1)];
        TestCollectUtt = TestCollectUtt(2:end); %adjust for the ','
        TestUtt_comp = strsplit(TestCollectUtt,',');
        Testu_utt = unique(TestUtt_comp);
        

        % first get the right title
        old_title = [visual_title];
        old_comp  = strsplit(old_title,',');
        mrmr_title = '';
        for rr = 1:length(feat_ind)
            mrmr_title = [mrmr_title ,',',old_comp{feat_ind(rr)}];
        end
        mrmr_title = mrmr_title(2:end);


        
        disp('begin writing to feature file/n');
        
        feat_fid = fopen(ffnn,'w');
        feat_test_fid = fopen(ffnn2,'w');
        fprintf(feat_test_fid, 'Emotions, utterances, speaker,%s\n',mrmr_title);
        fprintf(feat_fid, 'Emotions, utterances, speaker,%s\n',mrmr_title);
        
       feat_fid = fopen(ffnn,'w');
        feat_test_fid = fopen(ffnn2,'w');
        fprintf(feat_fid, 'Emotions, utterances, speaker,%s\n',mrmr_title);
        fprintf(feat_test_fid, 'Emotions, utterances, speaker,%s\n',mrmr_title);

        % write to feature file
        for rr = 1:size(CollectData,1)
            fprintf(feat_fid, '%d,', CollectLabel(rr)); % this is emotion
            
            utterance_id = 0;
            for ut_it = 1:length(u_utt)
                if strcmp(u_utt{ut_it},Utt_comp{rr} ) == 1
                    utterance_id = ut_it;
                end
            end
            fprintf(feat_fid, '%d, ', utterance_id);% this is uttearnce id

            fprintf(feat_fid, '%d ', CollectSPeaker(rr));% this is speaker id
            for comp_ind = 1:length(feat_ind)
                    fprintf(feat_fid, ',%f',CollectData(rr,comp_ind));
            end
            fprintf(feat_fid, '\n');
        end
        fclose(feat_fid);
            
        % write to test file
        for rr = 1:size(TestCollectData,1)
            fprintf(feat_test_fid, '%d,', TestCollectLabel(rr)); % this is emotion
            
            utterance_id = 0;
            for ut_it = 1:length(Testu_utt)
                if strcmp(Testu_utt{ut_it},TestUtt_comp{rr} ) == 1
                    utterance_id = ut_it;
                end
            end
            fprintf(feat_test_fid, '%d, ', utterance_id);% this is uttearnce id

            fprintf(feat_test_fid, '%d ', TestCollectSPeaker(rr));% this is speaker id
            for comp_ind = 1:length(feat_ind)
                    fprintf(feat_test_fid, ',%f',TestCollectData(rr,comp_ind));
            end
            fprintf(feat_test_fid, '\n');
        end
        fclose(feat_test_fid);

                
    end
    
    
    
end






%% end of file









%./mrmr -i ~/google_drive/Mturk_temp/SecondRoundEmotion/experiment2/FacialPointsProcess/Baseline/Round2Out/DataFile/winSize90/MRMR_LeaveoutF01.csv -t 1 -m MID -n 100 -v 50000 -s 99999 > ~/google_drive/Mturk_temp/SecondRoundEmotion/exper