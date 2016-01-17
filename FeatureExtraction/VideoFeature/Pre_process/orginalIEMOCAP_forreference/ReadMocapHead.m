function [labels2,points] = ReadMocapHead(fn)
	%input fn : file name (directory  to file)
	fid = fopen(fn,'r');
	labels = fgetl(fid);
    comp = strsplit(labels);
    labels2 = comp{1};
    for jj = 2:length(comp)
        labels2 = [labels2,',',comp{jj}];
        
    end
	tline = fgetl(fid); %useless, just showing what theses are
	points = [];
	while ~feof(fid)
		tline = fgetl(fid); 
		comp = strsplit(tline);
		points(end+1,1) = str2num(comp{1}); %frame
		for jj = 2:length(comp)
			points(end,jj) = str2num(comp{jj});
		end
	end
	fclose(fid);
end


%% end of file