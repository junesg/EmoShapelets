
for typpe = 1:3


    if typpe==1
        load('MajorityVote_Combined.mat');
    elseif typpe==2
        load('MajorityVote_Prototypic.mat');
    else
        load('MajorityVote_NonPrototypic.mat');
    end
    
%% check if this file has MOCAP features
disp('check to see timing --->');

if exist('MoreThanSec.mat')~=2 
    allVidFile = '../AudioFeatureExtract/AllWavFiles.csv';
    allMocapFile = '../MocapFeatureExtract/AllMocap.csv';

    ContainsFile = cell(0);
    for ii = 1:2
        ContainsFile{ii} = cell(0);
        if ii == 1
            fn = allVidFile;
        else
            fn = allMocapFile;
        end

        fid = fopen(fn,'r');

        while ~feof(fid)
            tline = fgetl(fid);
            if length(strtrim(tline) )<1 || tline(1)~='S',continue;end
                comp  = strsplit(tline,',');
                ContainsFile{ii}{end+1} = comp{1}(1:end-4);
        end
        fclose(fid);
    end



    disp('begin to collect utterances more than certain length');
    % check is this file has audio features and audio feature > 0.5s
    audExtractFolder = '/home/juneysg/google_drive/IEMOCAP_full_release/Code/AudioFeatureExtract/ExtractedData/winSize0.5s/';
    MoreThanHalfSec = cell(0);
    MoreThanOneSec = cell(0);
    MoreThanTwoSec = cell(0);
    audFiles = dir(audExtractFolder); %10041 files
    for aiter = 1:length(audFiles)
        aiter
        if audFiles(aiter).name(1) =='.', continue;end
        fid = fopen([audExtractFolder,audFiles(aiter).name ],'r');
        while ~feof(fid)
            tline = fgetl(fid);
        end
        comp = strsplit(tline,',');
        MaxlengthOfClip = str2num(comp{2});
        if MaxlengthOfClip > 0.5
            if MaxlengthOfClip > 1
                MoreThanOneSec{end+1} = audFiles(aiter).name(1:end-4);
                if MaxlengthOfClip > 2
                    MoreThanTwoSec{end+1} = audFiles(aiter).name(1:end-4);
                end
            end
            MoreThanHalfSec{end+1} = audFiles(aiter).name(1:end-4);
        end
        fclose(fid);
    end

    disp('beging to work with majority');

    save MoreThanSec.mat MoreThanTwoSec  MoreThanHalfSec  MoreThanOneSec ContainsFile;
else
    load('MoreThanSec.mat');
end



%% Check to see if the sentence contains no words (breathing or silences)

disp('check to see content --->');
NontrivialAudio = cell(0);
for jj = 1:length(Majority)
    fn = Majority{jj}.fileName;
    usable = CheckSentenceContent(fn);
    if usable
        NontrivialAudio{end+1} = fn;
    if mod(jj,100)==0
        jj
    end
    end
end




%% 



disp('counting --->');
Mod_maj = cell(0);
allEmoCat = cell(0);
allCount = [];
for jj = 1:length(Majority)
    if mod(jj,100)==0
        jj
    end
    if ~ismember(Majority{jj}.fileName, ContainsFile{1}) || ...
            ~ismember(Majority{jj}.fileName, ContainsFile{2}) || ...
            ~ismember(Majority{jj}.fileName, MoreThanHalfSec) || ...
            ~ismember(Majority{jj}.fileName,NontrivialAudio)
    else
        
        if ~ismember(Majority{jj}.Emotion{1},allEmoCat)
            allEmoCat{end+1} = Majority{jj}.Emotion{1};
            allCount(end+1) = 1;
        else
            allCount(find(strcmp(allEmoCat,Majority{jj}.Emotion{1})==1)) = allCount(find(strcmp(allEmoCat,Majority{jj}.Emotion{1})==1)) + 1;
        end
        Mod_maj{end+1} = Majority{jj};
    end
end
length(Mod_maj)


allEmoCat
allCount
typpe

if typpe==1
    save('MajorityVote_Combined_morethan1.mat','Mod_maj');
elseif typpe==2
    save('MajorityVote_Prototypic_morethan1.mat','Mod_maj');
else
    save('MajorityVote_NonPrototypic_morethan1.mat','Mod_maj');
end



end

