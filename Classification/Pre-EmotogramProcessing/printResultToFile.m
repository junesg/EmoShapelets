function printResultToFile(ResultMat,max_param_test,feature_size,fn)
	c_collect =  -12:2:2;
	g_collect = -12:2:2;

 	speakers = {'03','08','09','10','11','12','13','14','15','16'};
	fid = fopen(fn,'w');
	fprintf(fid,'test_speaker, feat_size, 2^g, 2^c, ')
	for speaker_id = 1:length(speakers)
		fprintf(fid,'speaker%s,', speakers{speaker_id});
	end
	fprintf(fid,'averageOfVal\n');

	for test_speaker_id = 1:length(speakers)
		for gg = 1:length(g_collect)
			for cc =1:length(c_collect)
				%print test speaker
				fprintf(fid,'%d,', test_speaker_id);
				% print feature size
				fprintf(fid,'%d,', feature_size);
				% print g and c
				fprintf(fid,'%d, %d,', g_collect(gg), c_collect(cc));
				% print sspeaker accuracies
				total_val = 0;
				for cv_speaker  = 1:length(speakers)
					fprintf(fid, '%f,',ResultMat{test_speaker_id}(cv_speaker,cc,gg) );
					 total_val =total_val + ResultMat{test_speaker_id}(cv_speaker,cc,gg);
				end
				fprintf(fid,'%f',total_val/(length(speakers)-1));
				fprintf(fid, '\n');
			end
		end
	end
	fclose(fid);
end
