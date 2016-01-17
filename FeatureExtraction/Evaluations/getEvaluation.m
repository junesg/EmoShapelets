function [utterances , utId]=  getEvaluation()

	curdir = pwd;
	folders = dir(['../../Session*']);

	utterances = cell(0);
	utId = 1;

	for ii = 1:length(folders)
		fileDirs = dir(['../../',folders(ii).name, '/dialog/EmoEvaluation/Ses*']);
		for ff = 1:length(fileDirs)
			fn = ['../../',folders(ii).name, '/dialog/EmoEvaluation/',fileDirs(ff).name];
			if exist(fn)~=2
				error([' file ', fn, ' does not exist! \n']);
			end
			ff
			%continue tlineo extract
			sentenList= readEmoEvalFile(fn);
			for ss = 1:length(sentenList)
				utterances{end+1} = sentenList{ss};
				utId = utId + 1 %how many sentences
			end

		end

	end

	save UtteranceRatings.mat utterances;
end


function [fileList]= readEmoEvalFile(fn)
	fid = fopen(fn,'r');
	tline  = fgetl(fid); %starter line, unnecessary
	tline = fgetl(fid);
	fileList = cell(0);

	while ~feof(fid)
		%each block of sentences and evaluations
		if  ~isempty(strfind(tline,'Ses'))
			comp = strsplit(tline);
			cccomp = strsplit(comp{4},'_');
			whoWears = cccomp{1}(end);
			whoTalks = cccomp{end}(1);
			
            if whoWears == whoTalks
                fileList{end+1}.fileName = comp{4};
			 	fileList{end}.Emotion = cell(0);
		
				while length(strtrim(tline)) > 1
					 if ~isempty(strfind(tline,'C-E')) 
					 	comp = strsplit(tline);
					 	fileList{end}.Emotion{end+1} = cell(0);
					 	for eee = 2:length(comp)-1
					 		fileList{end}.Emotion{end}{end+1} = strtrim(comp{eee});
					 	end
					 end
					tline = fgetl(fid);
                end
            else
                tline = fgetl(fid);
            end
		end		
			tline=fgetl(fid);
		
	end

	fclose(fid);

end


%% end of file
