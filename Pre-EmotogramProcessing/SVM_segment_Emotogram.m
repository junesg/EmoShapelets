function SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
% simple, multiclass SVM 4 class training for Happy, Angry , Sad and
% neutral, leave one speaker testing, leave one speaker out cross
% validation
% params.gs : 2^gs is the g value
% params.cs : 2^cs is teh c value
% params.fs : one of feature_sizes = [50,100,150,200];



addpath(genpath('../'));



wwss = {'0.25','0.125','0.5','1','2','Inf'};
emotions = {'F', 'W', 'T', 'N', 'E', 'A', 'L' };
speakers = {'03','08','09','10','11','12','13','14','15','16'};

feature_sizes = [50,100,150,200];

if ~ismember(window_size, wwss)
    error('Window size not found');
end


for speaker_id = test_speaker
    %speaker id is the one we leave out for testing.
    ffnn = ['AudioFeatureSelection/featureFiles/featureFile_winSize',window_size,'leaveout', ...
        speakers{speaker_id},'.csv'];
    ffnn2 = ['AudioFeatureSelection/featureFiles/featureFile_winSize',window_size,'leaveout', ...
        speakers{speaker_id},'_test.csv'];
    
    mrmrffnn = ['AudioFeatureSelection/mrmrFiles/mrmrFile_winSize',window_size,'leaveout', ...
        speakers{speaker_id},'.csv_results.txt'];
    
    [feat_ind, scores] = ReadFromMRMRFile(mrmrffnn);
    
    %error check for existence
    if exist(ffnn)~=2, error(['file ',ffnn,' does not exist']);end
    disp(['reading file ', ffnn ,' ------>']);
    
    %loop through feature size
    if trainBool
        for fs = 1:length(feature_sizes)
            run_SVM(speakers, speaker_id, ffnn, ...
                feature_sizes(fs), ffnn2, feat_ind,trainBool, params,window_size);
        end
    else
        run_SVM(speakers, speaker_id, ffnn, ...
            params.fs, ffnn2, feat_ind,trainBool, params,window_size);
    end
    
end




end



%% Savee dataset is small enough that we can use sub-window level calssficiation

function run_SVM(speakers, test_speaker, svm_train_file, ...
    feature_size, svm_test_contain,features_ind,trainBool, params,window_size)

% get training and validation data
disp('now get training data ----> ');
% check if file exists
if exist(svm_train_file)~=2, error([' file ',svm_train_file,' does not exist']); end
if exist(svm_test_contain)~=2, error([' file ',svm_train_file,' does not exist']);end
%read feature filse
disp(['Trianing file is ',svm_train_file]);
AllData = csvread(svm_train_file,1,0);
assert(size(AllData,2)==203);
%set parameters
c_collect =  -12:2:2;
g_collect = -12:2:2;
% get test data
disp('now get testing data ----> ');
test_AllData = csvread(svm_test_contain,1,0);
testData  = test_AllData(find(test_AllData(:,3)== test_speaker),:);
% get feature index
[val,order] = sort(features_ind,'ascend');
rel_ind = 1:200;
select_ind = rel_ind(find(order<=feature_size));
% get train and test data (overall)
trainData2 = AllData(:,...
    [1:3,select_ind+repmat(3,1,feature_size)]);
testData2  = testData(:,...
    [1:3,select_ind+repmat(3,1,feature_size)]);

%% loop through speakers


if trainBool % if training
    for aiter = 1: length(speakers) %this is the validation speaker
        if aiter== test_speaker, continue;end
        
        disp(['prepate trianing and validation data for actor ',num2str(aiter),'----> ']);
        
        trainData = AllData(find(AllData(:,3) ~= aiter), ...
            [1:3,select_ind+repmat(3,1,feature_size)]);
        valData   = AllData(find(AllData(:,3) == aiter), ...
            [1:3,select_ind+repmat(3,1,feature_size)]);
        
        for log2c = 1:length(c_collect)
            for log2g = 1:length(g_collect)
                cs = c_collect(log2c);
                gs = g_collect(log2g);
                
                disp(['now trainign with cs = ',num2str(cs),' and gs=',num2str(gs)]);
                
                validation_file = ['SVM_results/SVM_leaveout',speakers{test_speaker},...
                    '_fortest_and_validate',speakers{aiter},'_c=',num2str(cs),...
                    '_g=',num2str(gs),num2str(feature_size),'feauters','.txt'];
                test_file = ['SVM_results/SVM_leaveout',speakers{test_speaker},...
                    '_fortest_noValidation','_c=',num2str(cs),'_g=',num2str(gs),num2str(feature_size),'feauters','.txt'];
                
                if exist(validation_file) ~=2 %|| ...
                %         exist(test_file) ~= 2
                    
                    traind = trainData(:, 4:end);
                    trainl = trainData(:,1);
                    trainul = trainData(:,2);
                    trainal = trainData(:,3);
                    assert(size(traind,2) == feature_size);
                    
                    
                    bestParam  = [' -b 1 -c ', num2str(2^cs), ' -g ', num2str(2^gs),' ' ];
                    modelFile = overtrainBotGPU_feat(feature_size, test_speaker, trainl, traind, bestParam, aiter);
                    
                    vald = valData(:, 4:end);
                    vall = valData(:,1);
                    valul = valData(:,2);
                    valal = valData(:,3);
                    assert(size(vald,2) == feature_size);
                    
                    disp('predicting for valiation ----> ');
                    
                    [pred,acc2,decv1] = overpredictBotGPU_feat(feature_size, test_speaker,vall, vald, modelFile, aiter);
                    
                    dlmwrite(validation_file, [vall, valul, valal, decv1] ,'delimiter',',');
                    

                end
            end
        end
    end
else %if this is already testing
    
        gs = params.gs;
    cs = params.cs;
    test_file_results = ['SVM_results/SVM_FINAL_leaveout',speakers{test_speaker},...
        '_fortest_noValidation','_c=',num2str(cs),'_g=',num2str(gs),num2str(feature_size),'feauters','.txt'];
    
    traind = [trainData2(:, 4:end)];
    trainl = [trainData2(:,1)];
    trainul = [trainData2(:,2)];
    trainal = [trainData2(:,3)];
    assert(size(traind,2) == feature_size);
    
    
    bestParam  = [' -b 1 -c ', num2str(2^cs), ' -g ', num2str(2^gs),' ' ];
    modelFile = overtrainBotGPU_feat(feature_size, test_speaker, trainl, traind, bestParam, 1);
    
    % load all data
    testd = testData2(:, 4:end);
    testl = testData2(:,1);
    testul = testData2(:,2);
    testal = testData2(:,3);
    assert(size(testd,2) == feature_size);
    
    
    disp('predicting for test ----> ');
    [pred,acc2,decv1] = overpredictBotGPU_feat(feature_size, test_speaker,testl, testd, modelFile, 1);
    
    disp('accuracy is ')
    acc2
        dlmwrite(test_file_results, [testl, testul, testal, decv1] ,'delimiter',',');
     
        
    end

end


% end of file