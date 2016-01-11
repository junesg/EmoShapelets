function [ResultMat,max_param_test] = GatherResults(window_size,feature_size)



    features = [50,100,150,200];
    acc_multi = zeros(10,5);
    acc_oneVsAll = zeros(10,5);



    wwss = {'0.25','0.125','0.5','1','2','Inf'};
    emotions = {'F', 'W', 'T', 'N', 'E', 'A', 'L' };
    speakers = {'03','08','09','10','11','12','13','14','15','16'};



    c_collect =  -12:2:2;
    g_collect = -12:2:2;

    ResultMat = cell(length(speakers),1);
    % check for window size
    if ~ismember(window_size, wwss), error('The input window size is wrong');end
    if ~ismember(feature_size,features), error('the feautre size input is not correct');end


    for speaker_id = 1:length(speakers) %take out the test speaker
        disp(['the test speaker is ', speakers{speaker_id}]);
        
        %cross-validation for each speaker
        ResultMat{speaker_id} = zeros(length(speakers), length(c_collect), length(g_collect));
        
        for cv_speaker_id = 1:length(speakers)
            if cv_speaker_id == speaker_id, continue; end
            for cc = 1:length(c_collect)
                for gg = 1:length(g_collect)
                    svm_file = ['./SVM_results/SVM_leaveout',speakers{speaker_id},'_fortest_and_validate',...
                        speakers{cv_speaker_id},'_c=',num2str(c_collect(cc)),'_g=',...
                        num2str(g_collect(gg)), num2str(feature_size),'feauters.txt']; %'.txt']; %
                    if exist(svm_file) ~=2 
                        disp(['svm file ',svm_file,' does not exits']);
                    else
                        %[utt_acc, seg_acc] = 
                        [utt_acc7, seg_acc7, confusMat7, utt_acc4, seg_acc4, confusMat4 ] = ...
                            readFromSVMfile(svm_file);
                        ResultMat{speaker_id}(cv_speaker_id, cc, gg ) = utt_acc4;
                    end
                end
            end
        end
    end 

    max_param_test = zeros(2,length(speakers),1); % [ maxc; maxg]
       %save temporalily
    save('GatherResults.mat');


   	printResultToFile(ResultMat,max_param_test,feature_size,...
        ['OutputResultMatwin_',window_size,'_feature_',num2str(feature_size),'.csv']);




end






%% end of file