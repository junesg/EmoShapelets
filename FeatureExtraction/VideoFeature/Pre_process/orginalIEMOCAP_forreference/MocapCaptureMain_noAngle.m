
function  MocapCaptureMain_noAngle(type)

DataTypes = {'Combined','Prototypic','Nonprototypic'};

if type == 1
    load ('../Evaluations/MajorityVote_Combined_morethan0.5.mat');
elseif type ==2
    load ('../Evaluations/MajorityVote_Prototypic_morethan0.5.mat');
elseif type ==3
    load ('../Evaluations/MajorityVote_NonPrototypic_morethan0.5.mat');
else
    error('type should be 1 to 3');
end

% ans =   2446
% allEmoCat =  'Neutral;'    'Anger;'    'Sadness;'    'Happiness;'
% allCount =  390         497         466        1093
emotions = {'Happiness;','Anger;','Sadness;','Neutral;'};
Actors = {'Ses01F','Ses01M','Ses02F','Ses02M','Ses03F','Ses03M',...
    'Ses04F','Ses04M','Ses05F','Ses05M'};

fid = fopen('AllMocap.csv','r');
FileNames = cell(0);
RotPaths = cell(0);
HeadPaths = cell(0);

while ~feof(fid)
    tline = fgetl(fid);
    if length(strtrim(tline)) < 1 || tline(1) ~= 'S', continue;end
    comp  = strsplit(tline,',');
    FileNames{end+1} = comp{1}(1:end-4);
    RotPaths{end+1} = comp{6};
    HeadPaths{end+1} = comp{7};
end

fidd = fopen([DataTypes{type},'dataSummary_noAngle.txt'],'w');
TotalFilesUsed = 0;
TotalFilesDiscarded = 0;

% Fame_by_FrameDat = cell(0);

for jj = 1:length(Mod_maj)
    jj
    writeFile = false;
    if exist( ['ExtractedData_noAngle_noMissing/',Mod_maj{jj}.fileName,'.txt'])~=2
        writeFile = true;
        resultfile = fopen( ['ExtractedData_noAngle_noMissing/',Mod_maj{jj}.fileName,'.txt'],'w');
    end
    
    indexInMocap = find(strcmp(Mod_maj{jj}.fileName, FileNames)==1);
    if length(indexInMocap)~=1
        error(['can not find file ',Mod_maj{jj}.fileName,'\n']);
    end
    emotion = find(strcmp(emotions, Mod_maj{jj}.Emotion)==1);
    ul = jj;
    comp = strsplit(Mod_maj{jj}.fileName,'_');
    actorId = find(strcmp(comp{1}, Actors)==1);
    
    disp('getting points from AU');
    %         tic
    [true_labels, data] = ReadMocapRotate(RotPaths{indexInMocap});
    
    [a,b] = find(isnan(data));
    fprintf(fidd,'%d: %d row of data, %d has missing data, %d has missing data:',jj, size(data,1),length(unique(a)),length(unique(b)));

    if length(unique([unique(b)', 69,70,71,72,73,74])) > 6
        fprintf(fidd,' used?0\n');
        disp('discard')
        TotalFilesDiscarded =TotalFilesDiscarded + 1
        if writeFile
            writeFile = false;
            fclose(resultfile);
        end
        system( [' rm  ExtractedData_noAngle_noMissing/',Mod_maj{jj}.fileName,'.txt'] );
    else
        disp('safe')
        fprintf(fidd,' used?1\n');
        TotalFilesUsed = TotalFilesUsed+1
    end
    

    
    if writeFile
        [labels, points] = ReadMocapHead(HeadPaths{indexInMocap});
        [AUDat,AUlabel] = FromPointsToAU_noANGLE(data, true_labels);
        
        
        if sum( sum(AUDat(:,1:2) - points(:,1:2))) ~= 0
            error('Mismatching files?');
        end
        if size(AUDat,1) ~= size(points,1)
            error('mismatching datasizes?');
        end
        
        
        AUlabel_comp = strsplit(AUlabel,'Frame#,Time,');
        if length(strtrim(AUlabel_comp{1})) ~= 0
            error('AUlabel error?');
        end
        
        AUlabel = AUlabel_comp{2};
        
        TotalLabel = [labels,',',AUlabel];
        
        fprintf(   resultfile,'%s\n',TotalLabel);
        dlmwrite(['ExtractedData_noAngle_noMissing/',Mod_maj{jj}.fileName,'.txt'],...
            [points,AUDat(:,3:end)],'-append');
        fclose(resultfile);
    end
end
TotalFilesUsed
TotalFilesDiscarded
fclose (fidd);
% 	Fame_by_FrameDat{jj}.emotion = emotion;
% 	Fame_by_FrameDat{jj}.utterance = ul;
% 	Fame_by_FrameDat{jj}.fileName = Mod_maj{jj}.fileName;
% 	Fame_by_FrameDat{jj}.data = AUDat;
% 	Fame_by_FrameDat{jj}.rotate = points;
end


%save Fame_by_FrameDat.mat Fame_by_FrameDat true_labels labels;



%% end of file