% check sentence content

function usable = CheckSentenceContent(fn)
	IEMOCAPRoot = '/home/juneysg/google_drive/IEMOCAP_full_release/';

	% fn = Majority{1}.fileName;
	comp  = strsplit(fn,'_');
	session = str2num(comp{1}(4:end-1));


	direct = [IEMOCAPRoot,'Session',num2str(session),...
	'/sentences/ForcedAlignment/'];
	for jj =1:length(comp)-1
		direct =[direct,comp{jj},'_'];
	end
	direct = [direct(1:end-1),'/',fn,'.wdseg'];


	if exist(direct) ~= 2, 
		disp(['file ',fn,'.wdseg not found\n']); 
		usable = 0;
	else
		usable = readFromWdseg(direct);
	end

end



function nonTrivial = readFromWdseg(direct)
	fid = fopen(direct,'r');
	tline = fgetl(fid);
	nonTrivial = 0;
	while ~feof(fid)
		tline = fgetl(fid);
		if length(strtrim(tline)) > 1
			if strcmp(strtrim(tline(1:3)),'To') ~=1
				icom = strsplit(tline);
				allAlpha = 1;
				for jj =1:length(icom{end})
					if ~isalpha_num(icom{end}(jj))
						allAlpha = 0;
					end	
				end
				if allAlpha, nonTrivial =1;end
				
			end
		end
	end
	fclose(fid);
end

%% end of file