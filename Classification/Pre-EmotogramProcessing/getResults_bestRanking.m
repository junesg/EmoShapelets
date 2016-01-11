


window_size = 'Inf'
trainBool = false
test_speaker = 1;
params.gs= -6;
params.cs = 2;
params.fs = 50;

%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
window_size = '0.5'
SVM_generate_Emotogram(window_size,test_speaker, params,false);


test_speaker = 2;
params.gs= -8;
params.cs = 0;
params.fs = 150;
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
window_size = '0.5'
SVM_generate_Emotogram(window_size,test_speaker, params,false)


test_speaker = 3;
params.gs= -8;
params.cs = 0;
params.fs = 150;
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
window_size = '0.5'
SVM_generate_Emotogram(window_size,test_speaker, params,false);

test_speaker = 4;
params.gs= -6;
params.cs = 2;
params.fs = 50;
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
window_size = '0.5'
SVM_generate_Emotogram(window_size,test_speaker, params,false)






%% **** The above results are found using the ranking method from Analysis results
fd = './SVM_results/RankingResults/';
files = dir(fd);
utt_acc7 = cell(4,1);
seg_acc7= cell(4,1);
confusMat7= cell(4,1);
utt_acc4= cell(4,1);
seg_acc4= cell(4,1);
confusMat4= cell(4,1);

count_file = 1;
for ff = 1:length(files)
	if files(ff).name(1) == '.', continue; end
	if exist([fd,files(ff).name]) == 7, continue;end
    [utt_acc7{count_file}, seg_acc7{count_file}, confusMat7{count_file}, ...
    utt_acc4{count_file}, seg_acc4{count_file}, confusMat4{count_file} ] =...
     readFromSVMfile([fd,files(ff).name]);
     count_file = count_file+1;
end


cm4 = zeros(4,4);
cm7  = zeros(7,7);
ut4 = 0;
ut7 = 0;
%% now process the confusion matrix
for ff = 1:count_file-1
	cm4 = cm4 + confusMat4{ff};
	cm7  = cm7 + confusMat7{ff};
	ut4  = ut4  + utt_acc4{ff};
	ut7 = ut7 + utt_acc7{ff};
end

cm4 = cm4 ./ repmat(sum(cm4,2),1,4)
cm7 = cm7 ./repmat(sum(cm7,2),1,7)
ut4 = ut4/4
ut7 = ut7/4
std(cell2mat(utt_acc7))
mean(cell2mat(utt_acc7))
std(cell2mat(utt_acc4))
mean(cell2mat(u