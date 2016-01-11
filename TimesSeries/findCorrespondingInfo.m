function findCorrespondingInfo()
noAngle = 'noAngle';

% noAngle = 'withAngle';
for actors= 1:10
    trainf = ['Emotogram_leaveout_sec',num2str(actors),'train_',noAngle,'200features.txt'];
    testf = ['Emotogram_leaveout_sec',num2str(actors),'test_',noAngle,'200features.txt'];
    
    indexTrainf = ['DataSequenceswinSize0.25_',noAngle,'.txt'];
    contentIndex = dlmread(indexTrainf,',');
    content1 = dlmread(trainf, ',');
    content2 = dlmread(testf, ',');
    utterances1 = unique(content1(:,2));
    utterances2 = unique(content2(:,2));
    for emotions = 1:4
        %these are the training/testing files
        trainf_out = ['Series/Corr_TimeSeries_leave',num2str(actors),'train_',noAngle,'_emotion',num2str(emotions),'.txt'];
        test_out = ['Series/Corr_TimeSeries_leave',num2str(actors),'test_',noAngle,'_emotion',num2str(emotions),'.txt'];
        
       if exist(trainf_out) == 2
           system([' rm ',trainf_out]);
       end
        
       if exist(test_out) == 2
           system([' rm ',test_out]);
       end
       
       
        for ii = 1:length(utterances1)
            disp([' training ',num2str(ii),' ---->']);
            index = find(content1(:,2)==utterances1(ii));
            indexInTrainf = find(contentIndex(:,2)==utterances1(ii));
            
            if (length(index) ~=length(find(contentIndex(indexInTrainf,5)==1)));
                disp([' index has ',num2str(length(index)), ' and used utterances has ',...
                    num2str(length(find(contentIndex(indexInTrainf,5)==1))),'---->']);
            end
            
            if length(index) <= length(find(contentIndex(indexInTrainf,5)==1))
                sequencesUsage = ones(1,length(index));
            else
                sequencesUsage = contentIndex(indexInTrainf,5)'; %row vector of 1 or 0 
            end
            
            timeSeries = getRelevantInfo(sequencesUsage,content1(index,1:3));
            if length(timeSeries(:)) > 1
                dlmwrite(trainf_out,[unique(content1(index,1)), timeSeries],'-append','delimiter',',');
            end
        end
        
        
        for ii = 1:length(utterances2)
            disp([' test ',num2str(ii),' ---->']);

            index = find(content2(:,2)==utterances2(ii));
            indexInTrainf = find(contentIndex(:,2)==utterances2(ii));

%             assert(length(index) ==length(find(contentIndex(indexInTrainf,5)==1)));
            if (length(index) ~=length(find(contentIndex(indexInTrainf,5)==1)));
                disp([' index has ',num2str(length(index)), ' and used utterances has ',...
                    num2str(length(find(contentIndex(indexInTrainf,5)==1))),'---->']);
            end
            
            if length(index) <= length(find(contentIndex(indexInTrainf,5)==1))
                sequencesUsage = ones(1,length(index));
            else
                sequencesUsage = contentIndex(indexInTrainf,5)'; %row vector of 1 or 0 
            end
            
            
            timeSeries = getRelevantInfo(sequencesUsage,content2(index,1:3));
            if length(timeSeries(:)) > 1
                dlmwrite(test_out,[unique(content2(index,1)), timeSeries],'-append','delimiter',',');
            end
        end  
    end    
end
end



%these to get the information of the current utterance
function inform = getRelevantInfo(su,info)

    if sum(su) >= 1
        assert(length(unique(info(:,1)))==1);
        assert(length(unique(info(:,2)))==1);
        assert(length(unique(info(:,3)))==1);
        inform = [unique(info(:,1)),unique(info(:,2)),unique(info(:,3))];
    else
        inform = [];
    end
end