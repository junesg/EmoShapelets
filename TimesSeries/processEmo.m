function processEmo()
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
         
        trainf_out = ['Series/TimeSeries_leave',num2str(actors),'train_',noAngle,'_emotion',num2str(emotions),'.txt'];
        test_out = ['Series/TimeSeries_leave',num2str(actors),'test_',noAngle,'_emotion',num2str(emotions),'.txt'];
        
        if exist(trainf_out) == 2
            system([ 'rm ',trainf_out]);
        end
        
        if exist(test_out) == 2
            system([ 'rm ',test_out]);
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
            
            timeSeries = getTimeSeries(sequencesUsage,content1(index, emotions+3)');
            
            dlmwrite(trainf_out,[unique(content1(index,1)), timeSeries],'-append','delimiter',',');
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
            
            
%             sequencesUsage= content2(indexInTrainf,5)'; %row vector of 1 or 0 
            timeSeries = getTimeSeries(sequencesUsage,content2(index, emotions+3)');
            
            
            dlmwrite(test_out,[unique(content2(index,1)), timeSeries],'-append','delimiter',',');
        end
                
        
        
    end
    
    
    
end
end



function timeSeries = getTimeSeries(su,ls)
    assert(length(ls)==sum(su));
    
    timeSeries = 1:length(su);
    timeSeries(find(su==1))= ls;
    inn = find(su==1);
    
    %% cut off two ends if we need to
    if su(1)==0 %if the first one is not used, discard the first part
       timeSeries(1:inn(1)-1) = nan(1,inn(1)-1);
    end
    if su(end)==0 %if the last part is not used, make last part 
        timeSeries(inn(end)+1:end) = nan(1,length(length(ls)-inn(end)+1+1));
    end
    
    %% now start with interpolation of the middle
    if length(inn)<2
        timeSeries = [];
    else
        ii = inn(2);
        startZero= [];
        endZero = [];
        while ii <= inn(end)
            if su(ii-1) ==1 && su(ii) ==0
                startZero = [startZero, ii];
            end
            if su(ii-1)==0 &&  su(ii)==1
                endZero = [endZero,ii-1];
            end
            ii = ii +1;
        end
        assert(length(startZero)==length(endZero));
        for ii = 1:length(startZero)
            yval = timeSeries(startZero(ii)-1);
            rval = timeSeries(endZero(ii)+1);
            for jj = startZero(ii):1:endZero(ii)
                timeSeries(jj) = yval + (rval-yval)*((jj-startZero(ii))+1)/(endZero(ii)-startZero(ii)+2);
            end
        end
    
    end
    
end