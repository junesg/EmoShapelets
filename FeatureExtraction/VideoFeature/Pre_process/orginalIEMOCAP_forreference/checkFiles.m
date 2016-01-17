folders = dir('winSize0.5*');

for jj = 1:length(folders)
	files = dir([folders(jj).name,'/AllDataMocapDatawin*']);
	for kk = 1:length(files)
		fid = fopen([folders(jj).name,'/',files(kk).name],'r');
		fid_w = fopen([folders(jj).name,'/',files(kk).name,'_checked.csv'],'w');
		tline = fgetl(fid);
		fprintf(fid_w,'%s\n',tline);
		OlduttTo = 0;
		notQuit = 1;

		while ~feof(fid) && notQuit
			tline = fgetl(fid);
			if tline(1)=='E',
				notQuit = 0;
			else
				comp = strsplit(tline,',');
				NewuttTo = str2num(comp{2});
				if NewuttTo< OlduttTo, 
					notQuit = 0;
				else
					fprintf(fid_w,'%s\n',tline);
				end
			end
		end
		fclose(fid);
		fclose(fid_w);
	end	
end


%%end of file