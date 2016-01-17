function  getAllMocapData(type,noAngle)
if type ==1
    load('../Evaluations/MajorityVote_Combined_morethan0.5.mat');
elseif type ==2
    load('../Evaluations/MajorityVote_Prototypic_morethan0.5.mat');
else
    load('../Evaluations/MajorityVote_NonPrototypic_morethan0.5.mat');
end


%emotion index: 1,2,3,4
printedTitle = 0;
emotions = { 'Neutral;'    'Anger;'    'Sadness;'    'Happiness;'};
Actors = {'Ses01F','Ses01M','Ses02F','Ses02M','Ses03F','Ses03M',...
    'Ses04F','Ses04M','Ses05F','Ses05M'};

statisticsCont = {'mean_','std_','median_','skewness_','kurtosis_','25Perctile_','75Percentil_','range_','max_'};
% dataIndexOfMocap = [3,4,5,174:212, 213:232];
mocapFolder = '~/google_drive/IEMOCAP_full_release/Code/MocapFeatureExtract/ExtractedData/Additions/';

%Mod_maj
begin = 0;
for jj = 1:length(Mod_maj)
    jj
    AllData= [];%all data for this utterance
    if length(Mod_maj{jj}.Emotion)==1
        emo = find(strcmp(emotions, Mod_maj{jj}.Emotion{1})==1);
        fileName = [mocapFolder,Mod_maj{jj}.fileName,'.txt'];

        if  exist(fileName)~=2
            fprintf(['file ', fileName,' does not exst\n']);

        else

            comp2 = strsplit(Mod_maj{jj}.fileName,'_');
            ActorId = find(strcmp(comp2{1}, Actors)==1);

            fid = fopen(fileName,'r');
            tline = fgetl(fid);

            %% now initialize dataIndexOfMocap
            comp = strsplit(tline,',');
            dataIndexOfMocap = [];
            dataIndexOfMocap_noAngle = [];
            for ii = [3,4,5, 174:length(comp)]
                comp{ii};
                aa = [];
                bb = [];

                aa = [findstr('LLID',comp{ii})];
                bb = [findstr('RLID',comp{ii})];
                cc = findstr('ang',comp{ii});

                if length(aa(:)) < 1 && length(bb(:)) < 1
                    dataIndexOfMocap = [dataIndexOfMocap, ii];
                end
                
                if length(aa(:)) < 1 && length(bb(:)) < 1 && length(cc(:))<1
                    dataIndexOfMocap_noAngle = [dataIndexOfMocap_noAngle, ii];
                end
            end
            

            %%
            
            if noAngle
                dataIndexOfMocap = dataIndexOfMocap_noAngle;
            end
            
            
            
            if ~printedTitle
                comp = strsplit(tline,',');
                titleM = ['Emotion '];
                for ssiter = 1:length(statisticsCont)
                    for mmiter = 1:length(dataIndexOfMocap)
                        titleM = [titleM, ', ', statisticsCont{ssiter},comp{dataIndexOfMocap(mmiter)}];
                    end
                end
                % fprintf(mrmrfid, '%s\n',titleM);
                printedTitle = 1;
            end
            count = 0;
            totalTitleComp = length(strsplit(titleM,','));

            while ~feof(fid)
                tline = fgetl(fid);
                count = count+1;
                comp = strsplit(tline,',');
                AllData(end+1,1) = emo;
                AllData(end,2) = jj; %utterance index
                AllData(end,3) = ActorId; %actor index
                % dataLine = num2str(emo);
                for mmiter = 1:length(dataIndexOfMocap)
                    AllData(end,mmiter+3) = str2num(comp{dataIndexOfMocap(mmiter)});
                end
                %fprintf(mrmrfid,'%s\n',dataLine);
            end
            %     totalDataComp = size(AllData,2);
            %     if totalDataComp~=totalTitleComp
            %         totalTitleComp
            %         totalDataComp
            %         error('data size error?');
            %     end
            if count ~=size(AllData,1)
                error(['can not get the data correctly for file ',fileName]);
            end

            fclose(fid);


            disp('Finished colleciton data\n');
            %
            %     normalization,
            %     for aa = 1:length(Actors)
            %         AllData(find(AllData(:,3)==aa),4:end) = (AllData(find(AllData(:,3)==aa),4:end) - ...
            %             repmat( mean(AllData(find(AllData(:,3)==aa),4:end)),length(find(AllData(:,3)==aa)),1))./ ...
            %             repmat( std(AllData(find(AllData(:,3)==aa),4:end)),length(find(AllData(:,3)==aa)),1);
            %     end


            disp('Finish data normalization/n');
            %if length(find(isnan(AllData(:)))) < 1 
                [UseData,dataSize] =  PrintToFile(AllData,titleM,begin,type, noAngle);
                begin = 0;
                if dataSize~= totalTitleComp
                    dataSize
                    totalTitleComp
                    error('size mismatch');
                end
                disp('Finish data printing/n');
            %end
        end
    end
end
end


%%


function [UseData, dataSize] = PrintToFile(AllData,titleM,jjj,type, noAngle)


Datatypes = {'Combined', 'Prototypic','Nonprototypic'};


windowSizes = [0.25,Inf];
frameRate = 120;
slideSize = round(frameRate.*windowSizes);

emo = AllData(1,1);
ul = AllData(1,2);
ActorId = AllData(1,3);
statisticsCont = {'mean_','std_','median_','skewness_','kurtosis_','25Perctile_','75Percentil_','range_','max_'};


for jj = 1:length(slideSize)
    %correct numSec for Inf
    numSec = max(floor(size(AllData,1)/slideSize(jj)*2),2);
    
    
    ToDir = ['~/google_drive/IEMOCAP_full_release/Code/MocapFeatureExtract/winSize',...
        num2str(windowSizes(jj)),'s/',Datatypes{type},'/'];
    
    if exist(ToDir) ~= 7
        mkdir(ToDir);
    end
    
    if noAngle
        whereto= [ToDir,'MRMRMocapDatawinSize',num2str(windowSizes(jj)),'_noAngle.txt'];
    else
        whereto= [ToDir,'MRMRMocapDatawinSize',num2str(windowSizes(jj)),'_withAngle.txt'];
    end
    
    if noAngle
        allDataWhere = [ToDir,'AllDataMocapDatawinSize',num2str(windowSizes(jj)),'_noAngle.txt'];
    else
        allDataWhere = [ToDir,'AllDataMocapDatawinSize',num2str(windowSizes(jj)),'_withAngle.txt'];
    end
    
    if jjj == 1 %very first entry
        fid = fopen(whereto,'a');
        fid2 = fopen(allDataWhere,'a');
        fprintf(fid2,'%s,%s\n',['Emotion, Utterance, Actor'],titleM(10:end));
        fprintf(fid,'%s\n',titleM);
        fclose(fid2);
        fclose(fid);
    end
    

    for ssiter = 1:numSec-1
        UseData = true;
        startInd = max((ssiter-1)*slideSize(jj)/2+1,1);
        endInd = min((ssiter+1)*slideSize(jj)/2,size(AllData,1));
        if endInd <= startInd, continue;end
        CurrData = AllData(startInd:endInd,4:end);

        [a,b] = find(isnan(CurrData));

        uniqueCol = unique(b);
        for biter = 1:length(uniqueCol)
            if length(unique(a(find( b == uniqueCol(biter))))) >= size(CurrData,1)-2 %for this column, we don't even have 3 data points
                %dont use this data
                UseData = false;
            end
        end

        ToPrintData = [nanmean(CurrData),nanstd(CurrData), nanmedian(CurrData), skewness(CurrData), ...
            kurtosis(CurrData),prctile(CurrData,25),prctile(CurrData,75),...
            range(CurrData),nanmax(CurrData)];
        if ~UseData
            disp('Not used');
            ToPrintData = nan(size(ToPrintData));
        else
            disp('Used');
            if  length(find(isnan(ToPrintData)))  > 1
                ssiter
                jj
                error('data has nan?');
            end
        end

        dlmwrite(whereto,[emo,ToPrintData],'-append','delimiter',',');
        dlmwrite(allDataWhere,[emo,ul,ActorId,ToPrintData],'-append','delimiter',',');
        
    end
end

dataSize = size(ToPrintData,2)+1;

end


%% end of file