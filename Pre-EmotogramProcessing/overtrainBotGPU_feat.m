function [model] = overtrainBotGPU_feat(feature_size, test_speaker,y, x,cmd, aiter)
% This function builds K svm models, each responsible for class k versus the
% rest. 
%% I need to adjust the weight and the SMOTE to training each category
assert(size(y,1)==size(x,1))
svmModels = [num2str(test_speaker),'/tempSVMModels',num2str(aiter),'_'];
svmDir = '~/google_drive/Mturk_temp/SecondRoundEmotion/experiment2/FacialPointsProcess/libsvm-3.18/libsvm-3.17-GPU_x64-linux-v1.2/';
libsvmDir = '~/google_drive/Mturk_temp/SecondRoundEmotion/experiment2/FacialPointsProcess/libsvm-3.18/matlab/';
addpath(genpath(libsvmDir));

fprintf('train------>\n')

% INPUT: 
% x: an N x D data/feature matrix where N denotes the number of observations and
% D denotes feature dimensionality
% y: an N x 1 label vector, where each element y(n) in the nth row denotes
% the label of the observation x(n,:)
% cmd: the argument to control svm package

% Remarks: 
% 1) The code uses all the observations given in x for training
% 2) The label y is multiclass label, i.e. # of class can be greater than 2


labelSet = unique(y);
% Note: the labels in y are not necessarily in the non-skippy order, for
% instance, the labels can be {-1 3 10}.
labelSetSize = length(labelSet);
% models = cell(labelSetSize,1);
models = cell(0);


for i=1:labelSetSize
	disp(['training label ',num2str(i)]);
	tic
    newClassLab = double(y == labelSet(i));
    
    N =  max(1, floor((length(newClassLab)-sum(newClassLab))/sum(newClassLab)) );
 
    % print data to file
    libsvmwrite([num2str(test_speaker),'/tempSVMDataFile',num2str(aiter),'feat',num2str(feature_size),'.csv'], newClassLab, sparse(x));
    

    system([svmDir,'svm-train-gpu ', [cmd,'  -w1 ', num2str(N)],  ...
        [' ',num2str(test_speaker),'/tempSVMDataFile',num2str(aiter),'feat',num2str(feature_size),'.csv '],[svmModels,'class',num2str(i),'.txt '] ]);
     disp('finish writing')
     toc
    models{i} =[svmModels,'class',num2str(i),'.txt'];
end

model = struct('models', {models}, 'labelSet', labelSet);


end

%% end fof