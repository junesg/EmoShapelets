function [pred, ac, decv] = overpredictBotGPU_feat(feature_size,test_speaker,y, x, model,aiter)

%  svm-predict [options] test_file model_file output_file
    svmDir = '~/google_drive/Mturk_temp/SecondRoundEmotion/experiment2/FacialPointsProcess/libsvm-3.18/libsvm-3.17-GPU_x64-linux-v1.2/';
% 	addpath(genpath(svmDir));

labelSet = model.labelSet;
labelSetSize = length(labelSet);
models = model.models;
decv= zeros(size(y, 1), labelSetSize);



for i=1:labelSetSize
  newClassLab = double(y == labelSet(i));
  libsvmwrite([num2str(test_speaker),'/tempTestSVMDataFile',num2str(aiter),'feat',num2str(feature_size),'.csv'], newClassLab, sparse(x));
  svmoutputFile = [' ',num2str(test_speaker),'/tempTestSVMDataOutput',num2str(aiter),'feat',num2str(feature_size),'.txt'];
  %system( ['touch ',svmoutputFile]);
  system( [svmDir,'svm-predict  -q  -b 1'   , [' ',num2str(test_speaker),'/tempTestSVMDataFile',num2str(aiter),'feat',num2str(feature_size),'.csv '], models{i}, svmoutputFile]);
    
  [l, a, d] = getPredictionResults(svmoutputFile,y);
    % [l,a,d] = svmpredict(double(y == labelSet(i)), x, models{i});
  decv(:, i) = d %* (2 * models{i}.labelSet(1) - 1);
end

[tmp,pred] = max(decv, [], 2);
pred = labelSet(pred);
ac = sum(y==pred) / size(x, 1);

end


function  [l,a,d] = getPredictionResults(svmoutputFile,y)
	fnn = fopen(strtrim(svmoutputFile),'r');
	lline = fgetl(fnn);
	comp = strtrim(strsplit(lline,'labels'));
	fclose(fnn);
	labels = []
	for ii = 1:length(comp)
		if length(strtrim(comp{ii})) < 1, continue;end
		comp2 = strsplit(strtrim(comp{ii}),' ');
		for kk = 1:length(comp2)
			labels = [labels, str2num(comp2{kk})];
		end
	end

	content = dlmread( strtrim(svmoutputFile),' ',1,0);
	assert(size(content,1)==size(y,1));
	a = sum(y==content(:,1)) / size(content,1);
	l = content(:,1);

	d = content(:, find(labels==1) +1 );

end

%% end of file