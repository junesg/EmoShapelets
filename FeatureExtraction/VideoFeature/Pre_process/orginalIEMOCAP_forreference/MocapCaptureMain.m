
function  MocapCaptureMain()
load ('../Evaluations/MajorityVote_Prototypic_morethan0.5.mat');

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


% Fame_by_FrameDat = cell(0);

for jj = 1:length(Mod_maj)
	jj
    
    if exist( ['ExtractedData/',Mod_maj{jj}.fileName,'.txt'])~=2
        resultfile = fopen( ['ExtractedData/',Mod_maj{jj}.fileName,'.txt'],'w');


        indexInMocap = find(strcmp(Mod_maj{jj}.fileName, FileNames)==1);
        if length(indexInMocap)~=1
            error(['can not find file ',Mod_maj{jj}.fileName,'\n']);
        end
        emotion = find(strcmp(emotions, Mod_maj{jj}.Emotion)==1);
        ul = jj;
        comp = strsplit(Mod_maj{jj}.fileName,'_');
        actorId = find(strcmp(comp{1}, Actors)==1);

        disp('getting points from AU');
        tic
        [true_labels, data] = ReadMocapRotate(RotPaths{indexInMocap});
        [labels, points] = ReadMocapHead(HeadPaths{indexInMocap});
        [AUDat,AUlabel] = FromPointsToAU(data, true_labels);
        toc


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
        dlmwrite(['ExtractedData/',Mod_maj{jj}.fileName,'.txt'],...
            [points,AUDat(:,3:end)],'-append');
        fclose(resultfile);
    end
    
% 	Fame_by_FrameDat{jj}.emotion = emotion;
% 	Fame_by_FrameDat{jj}.utterance = ul;
% 	Fame_by_FrameDat{jj}.fileName = Mod_maj{jj}.fileName;	
% 	Fame_by_FrameDat{jj}.data = AUDat;
% 	Fame_by_FrameDat{jj}.rotate = points;
end


%save Fame_by_FrameDat.mat Fame_by_FrameDat true_labels labels;

end


%% end of file