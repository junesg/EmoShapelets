


window_size = 'Inf';
trainBool = false;
step_half= true;
test_speaker = 1
params.gs= -12
params.cs = 2
params.fs = 150
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);

test_speaker = 2
params.gs= -8
params.cs = 0
params.fs = 150
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);

test_speaker = 3
params.gs= -12
params.cs = 2
params.fs = 200
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);

test_speaker = 4
params.gs= -12
params.cs = 2
params.fs = 200
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);

test_speaker = 5
params.gs= -10
params.cs = 2
params.fs = 200
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);

test_speaker = 6
params.gs= -12
params.cs = 2
params.fs = 200
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);


test_speaker = 7
params.gs= -8
params.cs = 0
params.fs = 100
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);


test_speaker = 8
params.gs= -12
params.cs = 2
params.fs = 100
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);


test_speaker = 9
params.gs= -8
params.cs = 0
params.fs = 150
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);



test_speaker = 10
params.gs= -12
params.cs = 2
params.fs = 200
%SVM_segment_Emotogram(window_size,test_speaker, trainBool, params)
SVM_generate_Emotogram(window_size,test_speaker, params,step_half);







%% **** The above results are found using the ranking method from Analysis results
fd = './Emotograms/win0.5s_overlap0.1s/tradition/';
fd = './Emotograms/winInf/tradition/';

speakers = {'03','08','09','10','11','12','13','14','15','16'};

files = dir([fd,'*_test.txt']);
utt_acc7 = cell(length(speakers),1);
seg_acc7= cell(length(speakers),1);
confusMat7= cell(length(speakers),1);
utt_acc4= cell(length(speakers),1);
seg_acc4= cell(length(speakers),1);
confusMat4= cell(length(speakers),1);

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

assert(count_file == length(speakers)+1);

cm4 = cm4 ./ repmat(sum(cm4,2),1,4)
cm7 = cm7 ./repmat(sum(cm7,2),1,7)
ut4 = ut4/length(speakers)
ut7 = ut7/length(speakers)
std(cell2mat(utt_acc7))
mean(cell2mat(utt_acc7))
std(cell2mat(utt_acc4))
mean(cell2mat(utt_acc4))
