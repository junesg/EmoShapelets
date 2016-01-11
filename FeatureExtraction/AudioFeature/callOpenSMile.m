	
windowSizes = {'Inf','0.125','0.25','0.5','1.0','2'};
windowSizes  = {'Inf'};
overlap_half = true
overlap = 0.1;

for w_i=1:length(windowSizes)

	if overlap_half
		storageDir= ['ExtractedData/winSize',windowSizes{w_i},'s/'];
	else %if the overlap is not half
		storageDir= ['ExtractedData/winSize',windowSizes{w_i},'s_overlap',num2str(overlap),'s/'];
	end

	delete([storageDir,'*.csv']);
	
	filenames = 'EmoDBAudioSummary.csv';
	path_to_file = '/home/juneysg/google_drive/Savee/Code/AudioClassification/AudioFeatureExtract/';
	path_to_se = '/home/juneysg/google_drive/openSMILE-2.1.0/bin/linux_x64_standalone_static/SMILExtract';
	if overlap_half
		path_config = ['LocalFeature_Juneysg_csv',windowSizes{w_i},'.conf'];
	else
		path_config = ['LocalFeature_Juneysg_csv',windowSizes{w_i},'_overlap',num2str(overlap),'s.conf'];
	end

	filedirs = cell(0);
	fid = fopen(filenames,'r');
	tline = fgetl(fid);
	comp = strsplit(tline,',');
	location = 0;
	for ii =1:length(comp)
		if strcmp(strtrim(comp{ii}),'Path' ) ==1
				location = ii;
		end
	end

	while ~feof(fid)
			tline = fgetl(fid);
			comp = strsplit(tline,',');
			fd = comp{location};
			storage_filename = [storageDir,comp{1}];
			storage_filename = strsplit(storage_filename,'.wave');
			storage_filename = storage_filename{1};
			storage_filename = [storage_filename,'.csv'];
			cmd = [path_to_se,' -C ', path_config, ' -I ', fd,' -O ',storage_filename];
			system(cmd);

	end
	
end