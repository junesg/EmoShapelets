function [acc,confuseMat] = get_cv_acLOSO(y,x,param,act,ul)

%leave one speaker out cross validation
% y is training label (no tst speaker) , x is training data
% param is the Svm parameters command, 
% act is the actorlabel (leave one actor out validation)
% ut is the utterance label (used for prediction)


allActorIndex = unique(act);
nr_fold = length(allActorIndex);
ac = zeros(nr_fold,1);
confuseMat = zeros(4,4);

for i=1:nr_fold % Cross training : folding
  test_ind= find(act==allActorIndex(i));
  train_ind = find(act~=allActorIndex(i));  
  model = overtrainBot(y(train_ind),x(train_ind,:),param,0); %last one is for no smote
  [pred,a,decv] = overpredictBot(y(test_ind),x(test_ind,:),model);
%   utt = ul(test_ind);
%   uniq_utt = unique(utt);
%   for iterU = 1:length(uniq_utt)
%      pred_u =  mode(pred(find(utt == uniq_utt(iterU))));
%      actual_u = mode(y(find(utt == uniq_utt(iterU))));
%      ac = ac + (pred_u==actual_u);
%      len = len+1;
%   end
  	[ac(i), confuseMat2] = getAccuracy_max(pred, y(test_ind), ul(test_ind));
    confuseMat = confuseMat + confuseMat2;
%   ac = ac + sum(y(test_iconfuseMat2nd)==pred);
end
confuseMat = confuseMat./nr_fold;

fprintf('\nCross-validation unweighted 4 class Accuracy = %g%%\n', mean(ac) * 100);
fprintf('cross-validation confusion mat : \n');
disp(confuseMat)
acc = mean(ac);
end


%% end of file