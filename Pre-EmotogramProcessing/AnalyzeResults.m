function AnalyzeResults(window_size, byRankBool )

    wwss = {'0.25','0.125','0.5','1','2','Inf'};
	assert(ismember(window_size,wwss));

    features = [50,100,150,200];

    emotions = {'F', 'W', 'T', 'N', 'E', 'A', 'L' };
    speakers = {'03','08','09','10','11','12','13','14','15','16'};


	   
	collect_data = [];
	% first get all the data
	for test_speaker = 1:length(speakers)
		for ff = 1:length(features)
			feature_size = features(ff);
			fn =['OutputResultMatwin_',window_size,'_feature_',num2str(feature_size),'.csv'];
			% fid = fopen(fn,'r');
			collect_data = [collect_data; csvread(fn,1,0)];
		end
    end

    if byRankBool
        f_wn = 'BestRankingParamsFile.csv';
    else
        f_wn = 'BestParamFile.csv';
    end
	fid = fopen(f_wn,'w');
	fprintf(fid,'test speaker:, best 2^g, best 2^c, best f, best acc\n ');

    % for each test speaker, then start looking at the rank of g,c,f for each validation speaker
    for test_speaker = 1:length(speakers)
        if byRankBool
            [best_gs, best_cs, best_fs, best_acc] = getBestParam_ranking(collect_data,test_speaker);
        else
            [best_gs, best_cs, best_fs, best_acc] = getBestParam(collect_data,test_speaker);
        end
    	for ii = 1:length(best_gs)
    		fprintf(fid,'%d, %d, %d, %d, %f\n ', ...
    			test_speaker, best_gs(ii), best_cs(ii), best_fs(ii), best_acc(ii));
    	end
    end

    fclose(fid);

	if byRankBool
	    fd = './SVM_results/RankingResults/';
	else
	    fd = './SVM_results/TraditionalResults/';
	end

	% files = dir(fd);
	% utt_acc = [];
	% seg_acc = [];
	% for ff = 1:length(files)
	%     if files(ff).name(1) == '.', continue; end
	%         files(ff).name
	%         [utt_acc2, seg_acc2] = readFromSVMfile([fd,files(ff).name]);
	%         seg_acc = [seg_acc, seg_acc2]
	%         utt_acc = [utt_acc, utt_acc2]    
	% end

end



function [best_gs, best_cs, best_fs, best_acc] = getBestParam(collect_data,test_speaker)
    %now start getting the ranks for each validation speaker
	index_concern = find(collect_data(:,1) == test_speaker);
	relevantData= collect_data(index_concern,:);
	
	
    [maxVal, ind] = sort(relevantData(:,end),'descend');
    
    
    rank_ind = ind(1)
  
	best_gs = relevantData(rank_ind,3);
	best_cs = relevantData(rank_ind,4);
	best_fs = relevantData(rank_ind,2);
	best_acc = relevantData(rank_ind,end);


end




function [best_gs, best_cs, best_fs, best_acc] = getBestParam_ranking(collect_data,test_speaker)

	%now start getting the ranks for each validation speaker
	index_concern = find(collect_data(:,1) == test_speaker);
	relevantData= collect_data(index_concern,:);
	order = zeros(length(index_concern),1);
	for val_speaker = 1:10
		if val_speaker == test_speaker, continue; end
		new_rank = zeros(length(index_concern),1);
		[value, order2] = sort(relevantData(:,val_speaker+4),'descend');
		for ad = 1:length(order2)
			new_rank(order2(ad)) = ad;
		end
		order = order + new_rank;
	end

	[val,rank_ind ] = min(order)
	best_gs = relevantData(rank_ind,3);
	best_cs = relevantData(rank_ind,4);
	best_fs = relevantData(rank_ind,2);
	best_acc = relevantData(rank_ind,end);

end


%% end of file