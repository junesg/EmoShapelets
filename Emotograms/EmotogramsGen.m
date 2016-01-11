%generate Emotogram
function EmotogramsGen(fileType)
if ~ismember(fileType,[1,2,3])
    disp('please enter 1 (AudioVisual),2(Audio),or 3(Visual) as input');
end

wwss = {'0.25','0.125','0.5','1','2', 'Inf'};
window_size ='0.5';
step_size = '0.1';
emotions = {'F', 'W', 'T', 'N', 'E', 'A', 'L' };
speakers = {'03','08','09','10','11','12','13','14','15','16'};

AudioVisualFolder = {['winSize',window_size,'s_overlap',step_size,'s/Audio']};
%['winSize',window_size,'s_overlap',step_size,'s/Audiovisual'], ...
%    ['winSize',window_size,'s_overlap',step_size,'s/Audio']};%, ...
%    ['winSize',window_size,'s_overlap',step_size,'s/Visual']};


for actors= 8:length(speakers)
    % train file
    trainf = [AudioVisualFolder{fileType},'/Emotogram_leaveout_sec', ...
        speakers{actors},'train_.txt'];
    % test file
    testf = [AudioVisualFolder{fileType},'/Emotogram_leaveout_sec',...
        speakers{actors},'test_.txt'];
    % file prefix for the SVM output (original program output)
    filePrefix = ['SVM_FINAL_leaveout', speakers{actors}, '_fortest_noValidation_' ];
    
    % the content of the files
    trainContent = [];
    testContent = [];
    
    %now find the file 
    files = dir(AudioVisualFolder{fileType});
    for ii = 1:length(files)
        if files(ii).name(1)~='.' % if this is not the directory
        if isdir(   [AudioVisualFolder{fileType},'/',files(ii).name]), continue;end 
            if strcmp(filePrefix, files(ii).name(1:length(filePrefix)))==1 % if this is speaker
                comps =strsplit( files(ii).name, '_');
                comp = strsplit(comps{end}, '.');
                tttype = comp{1};
                if strcmp(tttype,'train')==1 % if this is train file, then we 
                    trainContent = dlmread([AudioVisualFolder{fileType},'/',files(ii).name]);
                else % if it is test file, 
                    testContent  = dlmread([AudioVisualFolder{fileType},'/',files(ii).name]);
                end
            end
        end
    end
        
    % check the read inputs 
    assert(~isempty(trainContent));
    assert(~isempty(testContent));
    
    trainContent(:,2) = trainContent(:,1).*10000+ trainContent(:,2).*100+trainContent(:,3);
    testContent(:,2) = testContent(:,1).*10000+ testContent(:,2).*100+testContent(:,3);

    % now we get the inputs
    train_utterances = unique(trainContent(:,2));
    test_utterances = unique(testContent(:,2));

    size(test_utterances)
    
    train_speakers = unique(trainContent(:,3));
    test_speakers = unique(testContent(:,3));
    
    % now emotion output
    for emotions = 1:4
        
        %these are the training/testing files
        trainf_out = [AudioVisualFolder{fileType},'/Series/Corr_TimeSeries_leave',speakers{actors},'train_emotion',num2str(emotions),'.txt'];
        test_out = [AudioVisualFolder{fileType},'/Series/Corr_TimeSeries_leave',speakers{actors},'test_emotion',num2str(emotions),'.txt'];

        %check to make sure they don't exist
        if exist(trainf_out) == 2
           system([' rm ',trainf_out]);
        end

        if exist(test_out) == 2
           system([' rm ',test_out]);
        end
        
        % for each unique utterance, get the values of the sequences
        for ii = 1:length(train_utterances)
            for speaker_id = 1:length(train_speakers)
                disp([' writing data for training ',num2str(ii),' ---->']);
                index = find(trainContent(:,2)==train_utterances(ii));
                index = intersect(index, find(trainContent(:,3)==train_speakers(speaker_id)) );
                %check if the index exists
                if length(index) >= 1
                    timeSeries = getRelevantInfo(index,trainContent(index,:),emotions);

                    if length(timeSeries(:)) > 1
%                         unique(trainContent(index,1))
%                         size(timeSeries)
%                         
                        dlmwrite(trainf_out,[unique(trainContent(index,1)), timeSeries],'-append','delimiter',',');
                    end
                end
            end
        end
        
        % for each unique utterance, get the values of the sequences
        for ii = 1:length(test_utterances)
            for speaker_id = 1:length(test_speakers)
                disp([' writing data for testing ',num2str(ii),' ---->']);
                index = find(testContent(:,2)==test_utterances(ii));
                index = intersect(index,find(testContent(:,3)==test_speakers(speaker_id)) );

                timeSeries = getRelevantInfo(index,testContent(index,:),emotions);

                if length(timeSeries(:)) > 1
                    dlmwrite(test_out,[unique(testContent(index,1)), timeSeries],'-append','delimiter',',');
                else
                    error(['utterance ',num2str(ii),' speaker ',num2str(speaker_id),'time series is smaller than 1?']);
                end
            end
        end
        
    end    
end
end



%these to get the information of the current utterance
function inform = getRelevantInfo(su,info,emotions)

    if length(su) >= 1
        assert(length(unique(info(:,1)))==1);
        assert(length(unique(info(:,2)))==1);
        assert(length(unique(info(:,3)))==1);
        inform = info(:,emotions+3)';
    else
        inform = [];
    end
    
end


%% end of file