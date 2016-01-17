function [titleM,AllData ]= getAllAudioData(kk,type)

if ~ismember(kk,[0.125,0.25,0.5,1,1.5,2 ,Inf])
    error('Enter a number from 0.125,0.25,0.5,1,1.5,2 or Inf(s)');
end

audFolder = ['~/google_drive/IEMOCAP_full_release/Code/AudioFeatureExtract/ExtractedData/winSize',num2str(kk),'s/'];

printedTitle = 0;

if type==1
    load('~/google_drive/IEMOCAP_full_release/Code/Evaluations/MajorityVote_Combined_morethan0.5.mat');
elseif type ==2
    load('~/google_drive/IEMOCAP_full_release/Code/Evaluations/MajorityVote_Prototypic_morethan0.5.mat');
elseif type == 3
    load('~/google_drive/IEMOCAP_full_release/Code/Evaluations/MajorityVote_NonPrototypic_morethan0.5.mat');
else
    error('enter type from 1(combined), 2(prototypic), 3(non-prototypic)');
end

% emotion index: 1,2,3,4
emotions = {'Happiness;','Anger;','Sadness;','Neutral;'};

Actors = {'Ses01F','Ses01M','Ses02F','Ses02M','Ses03F','Ses03M',...
    'Ses04F','Ses04M','Ses05F','Ses05M'};
AllData = [];
AcotrInd = [];


%Mod_maj
for jj = 1:length(Mod_maj)
    jj
    
    if length(Mod_maj{jj}.Emotion) ==1
        emo = find(strcmp(emotions, Mod_maj{jj}.Emotion{1})==1);
        fileName = [audFolder,Mod_maj{jj}.fileName,'.csv'];
        if  exist(fileName)~=2
            error(['file ', fileName,' does not exst\n']);
        end

        comp2 = strsplit(Mod_maj{jj}.fileName,'_');
        ActorId = find(strcmp(comp2{1}, Actors)==1);


        fid = fopen(fileName,'r');
        tline = fgetl(fid);
        if ~printedTitle
            comp = strsplit(tline,',');
            titleM = ['Emotion '];
            for jj = 3:length(comp)
                titleM = [titleM, ', ', comp{jj}];
            end
            % fprintf(mrmrfid, '%s\n',titleM);
            printedTitle = 1;
        end

        while ~feof(fid)
            tline = fgetl(fid);
            comp = strsplit(tline,',');

            AllData(end+1,1) = emo;
            AllData(end,2) = jj; %utterance index
            AllData(end,3) = ActorId; %actor index
            AcotrInd(end+1) = ActorId;

            % dataLine = num2str(emo);
            for jj = 3:length(comp)
                % dataLine = [dataLine,', ',comp{jj}];
                AllData(end,jj+1) = str2num(comp{jj});
            end
            %fprintf(mrmrfid,'%s\n',dataLine);
        end
        fclose(fid);
    end
    
    
end

disp('Finished colleciton data, starts actor normalization\n');



% normalization,
for aa = 1:length(Actors)
    AllData(find(AllData(:,3)==aa),4:end) = (AllData(find(AllData(:,3)==aa),4:end) - ...
        repmat( mean(AllData(find(AllData(:,3)==aa),4:end)),length(find(AllData(:,3)==aa)),1))./ ...
        repmat( std(AllData(find(AllData(:,3)==aa),4:end)),length(find(AllData(:,3)==aa)),1);
end

disp('Finish data normalization/n');

AllData(find(isnan(AllData))) = zeros(size(find(isnan(AllData))));


end

%% end of file