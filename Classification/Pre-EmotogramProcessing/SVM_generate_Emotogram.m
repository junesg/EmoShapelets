function SVM_generate_Emotogram(window_size,test_speaker, params,step_half)
% simple, multiclass SVM 4 class training for Happy, Angry , Sad and
% neutral, leave one speaker testing, leave one speaker out cross
% validation
% params.gs : 2^gs is the g value
% params.cs : 2^cs is teh c value
% params.fs : one of feature_sizes = [50,100,150,200];


addpath(genpath('./'));

wwss = {'0.25','0.125','0.5','1','2','Inf'};
emotions = {'F', 'W', 'T', 'N', 'E', 'A', 'L' };
speakers = {'03','08','09','10','11','12','13','14','15','16'};
feature_sizes = [50,100,150,200];


step_size = '0.1';



if ~ismember(window_size, wwss)
    error('Window size not found');
end



for speaker_id = test_speaker
    %speaker id is the one we leave out for testing.
    if step_half
        appendix = '';
    else
        appendix = ['_overlap',step_size];
    end

    train_ffnn = ['./AudioFeatureSelection/featureFiles/featureFile_winSize','Inf','leaveout', ...
        speakers{speaker_id},'.csv']; % training dataset
    mrmrffnn = ['./AudioFeatureSelection/mrmrFiles/mrmrFile_winSize','Inf','leaveout', ...
        speakers{speaker_id},'.csv_results.txt'];


    ffnn = ['./AudioFeatureSelection/featureFiles/featureFile_winSize',window_size,'leaveout', ...
        speakers{speaker_id},appendix,'.csv'];
    ffnn2 = ['./AudioFeatureSelection/featureFiles/featureFile_winSize',window_size,'leaveout', ...
        speakers{speaker_id},appendix,'_test.csv'];
    

    
    [feat_ind, scores] = ReadFromMRMRFile(mrmrffnn);
    
    %error check for existence
    if exist(ffnn)~=2, error(['file ',ffnn,' does not exist']);end
    disp(['reading file ', ffnn ,' ------>']);
    
    %loop through feature size
    run_SVM(speakers, speaker_id, train_ffnn, ...
            params.fs, ffnn, ffnn2, feat_ind, params, window_size, appendix);
    
end




end



%% Savee dataset is small enough that we can use sub-window level calssficiation

function run_SVM(speakers, test_speaker, svm_train_file, ...
    feature_size, svm_train_contain, svm_test_contain,features_ind, params,window_size,appendix)

% get training and validation data
disp('now get training data ----> ');

% check if file exists
if exist(svm_train_file)~=2, error([' file ',svm_train_file,' does not exist']); end
if exist(svm_test_contain)~=2, error([' file ',svm_train_file,' does not exist']);end
if exist(svm_train_contain)~=2, error([' file ',svm_train_contain,' does not exist']);end


%read feature filse
AllData = csvread(svm_train_file,1,0);
assert(size(AllData,2)==203);


% get test data
disp('now get testing data ----> ');
emotogram_test_data = csvread(svm_test_contain,1,0);
emotogram_train_data = csvread(svm_train_contain,1,0);


% get feature index
[val,order] = sort(features_ind,'ascend');
rel_ind = 1:200;
select_ind = rel_ind(find(order<=feature_size));
% get train and test data (overall)
trainData2 = AllData(:,...
    [1:3,select_ind+repmat(3,1,feature_size)]);
emotogram_test_data2  = emotogram_test_data(:,...
    [1:3,select_ind+repmat(3,1,feature_size)]);
emotogram_train_data2  = emotogram_train_data(:,...
    [1:3,select_ind+repmat(3,1,feature_size)]);
%% loop through speakers


gs = params.gs;
cs = params.cs;
train_file_results = ['Emotograms/SVM_FINAL_leaveout',speakers{test_speaker},...
    '_fortest_noValidation','_c=',num2str(cs),'_g=',num2str(gs),num2str(feature_size),'feauters',appendix,'_train.txt'];
test_file_results = ['Emotograms/SVM_FINAL_leaveout',speakers{test_speaker},...
    '_fortest_noValidation','_c=',num2str(cs),'_g=',num2str(gs),num2str(feature_size),'feauters',appendix,'_test.txt'];


traind = [trainData2(:, 4:end)];
trainl = [trainData2(:,1)];
trainul = [trainData2(:,2)];
trainal = [trainData2(:,3)];
assert(size(traind,2) == feature_size);


bestParam  = [' -b 1 -c ', num2str(2^cs), ' -g ', num2str(2^gs),' ' ];
modelFile = overtrainBotGPU_feat(feature_size, test_speaker, trainl, traind, bestParam, 1);


% load all data for emotogram test
testd = emotogram_test_data2(:, 4:end);
testl = emotogram_test_data2(:,1);
testul = emotogram_test_data2(:,2);
testal = emotogram_test_data2(:,3);
assert(size(testd,2) == feature_size);

disp('predicting for test ----> ');
[pred,acc2,decv1] = overpredictBotGPU_feat(feature_size, test_speaker,testl, testd, modelFile, 1);
disp('accuracy is ')
acc2
dlmwrite(test_file_results, [testl, testul, testal, decv1] ,'delimiter',',');



% load all data for emotogram train
testd = emotogram_train_data2(:, 4:end);
testl = emotogram_train_data2(:,1);
testul = emotogram_train_data2(:,2);
testal = emotogram_train_data2(:,3);
assert(size(testd,2) == feature_size);
disp('predicting for test ----> ');
[pred,acc2,decv1] = overpredictBotGPU_feat(feature_size, test_speaker,testl, testd, modelFile, 1);
disp('accuracy is ')
acc2
dlmwrite(train_file_results, [testl, testul, testal, decv1] ,'delimiter',',');
 

    
end




% end of file