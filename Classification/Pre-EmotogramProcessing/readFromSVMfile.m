
function [utt_acc7, seg_acc7, confusMat7, utt_acc4, seg_acc4, confusMat4 ] = readFromSVMfile(fn)
    % returns both utterance level accuracies, 
    % also returns 

    data= csvread(fn);
    label = data(:,1);
    utterances_id = data(:,1).*1000+ data(:,3).*100+data(:,2);
    actors = data(:,3);
    probabilites  =  data(:,4:end);

    unique_utterance = unique(utterances_id);
    utt_correct7  = 0;
    seg_correct7 = 0;
    utt_wrong7 = 0;
    seg_wrong7 = 0 ;

    utt_correct4  = 0;
    seg_correct4 = 0;
    utt_wrong4 = 0;
    seg_wrong4 = 0 ;


    % get ready for 
    confusMat7 = zeros(7,7);
    confusMat4 = zeros(4,4);



    for uu = 1:length(unique_utterance)
        this_utt_id = unique_utterance(uu);
        this_utt_lab = unique(label(find(utterances_id==this_utt_id)));
        assert(length(this_utt_lab) ==1);

        % first process class 7
        total_prob = sum(probabilites(find(utterances_id==this_utt_id),:),1);
        [junk, this_utt_pred] = max(total_prob); 
        if ismember(this_utt_lab,this_utt_pred)
            utt_correct7 = utt_correct7+ 1;
        else
            utt_wrong7 = utt_wrong7 + 1;
        end
        confusMat7(this_utt_lab, this_utt_pred)  = confusMat7(this_utt_lab, this_utt_pred)+1;
        
        % process happy angry sad and neutral
        total_prob = sum(probabilites(find(utterances_id==this_utt_id),1:4),1);
        [junk, this_utt_pred] = max(total_prob); 
        if ~ismember(this_utt_lab,1:4),continue;end
        if ismember(this_utt_lab,this_utt_pred)
            utt_correct4 = utt_correct4 + 1;
        else
            utt_wrong4 = utt_wrong4 + 1;
        end
        confusMat4(this_utt_lab, this_utt_pred)  = confusMat4(this_utt_lab, this_utt_pred)+1;
    end


    for ii = 1:length(label)
        [junk, this_seg_pred7] = max(probabilites(ii,:)); 
        [junk, this_seg_pred4] = max(probabilites(ii,:)); 
        % segment for 7 classes
        if ismember(label(ii), this_seg_pred7)
            seg_correct7 = seg_correct7+ 1;
        else
            seg_wrong7 = seg_wrong7 +1;
        end
        %seg for four classes
        if ismember(label(ii), this_seg_pred4)
            seg_correct4 = seg_correct4+ 1;
        else
            seg_wrong4 = seg_wrong4 +1;
        end

    end

    utt_acc7 = utt_correct7/(utt_correct7+ utt_wrong7);
    seg_acc7 = seg_correct7/(seg_correct7+seg_wrong7);
    utt_acc4 = utt_correct4/(utt_correct4+ utt_wrong4);
    seg_acc4 = seg_correct4/(seg_correct4+seg_wrong4);
 

end
