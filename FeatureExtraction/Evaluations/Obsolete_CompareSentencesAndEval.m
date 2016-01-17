file = ['../AudioFeatureExtract/AllWavFiles.csv'];
fid = fopen(file,'r');
load('UtteranceRatings.mat');

sentenceNames = cell(0);

while ~feof(fid)
	tline = fgetl(fid);
	if length(strtrim(tline)) < 1, continue;end
	if tline(1) ~= 'S', continue;end
	comp = strsplit(tline,',');
	sentenceNames{end+1} = comp{1}(1:end-4);
end
fclose(fid);

length(sentenceNames)



missing = cell(0);

for ii  = 1:length(sentenceNames)
	ii
	found = 0;
	for jj = 1:length(utterances)
		if strcmp(utterances{jj}.fileName, sentenceNames{ii}) ==1 
			found = 1;
		end
	end
	if ~found 
		missing{end+1} = sentenceNames{ii};
	end
end




%% end of file