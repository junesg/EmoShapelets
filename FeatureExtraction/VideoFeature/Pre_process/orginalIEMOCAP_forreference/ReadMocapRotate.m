function [true_labels, data] = ReadMocapRotate(fn)


	fid = fopen(fn,'r');
	labels = fgetl(fid);
	comp = strsplit(labels);
	true_labels= [comp{1}, ',',comp{2}];
	tline = fgetl(fid); %useless, just showing what theses are
	comp2 =  strsplit(tline);
	data = [];

	for jj = 3:length(comp)
		for kk = (jj-3)*3+1:(jj-2)*3
			true_labels = [true_labels, ',', comp{jj},'_',comp2{kk}];
		end
	end


	while ~feof(fid)
		tline = fgetl(fid);
		comp = strsplit(tline);
		data(end+1,1) = str2num(comp{1}); %frame
		for jj = 2:length(comp)
			data(end,jj) = str2num(comp{jj});
		end
	end


	fclose(fid);


end


%% end of file