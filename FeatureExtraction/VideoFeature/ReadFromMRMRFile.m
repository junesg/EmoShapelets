function [FeaturesIndices, Scores] = ReadFromMRMRFile(MRMRFileName)
    %output of the previous file (rmrm file)
    fileName = MRMRFileName;
    if exist(fileName) ==2
    else
        error(strcat('File: ', fileName, ' does not exist~'));
    end
    fid_r = fopen(fileName, 'r');
    tline = fgetl(fid_r);
    while ~feof(fid_r) && (length(tline)< 1||(strcmp(tline, '*** mRMR features *** ')~=1 ))
        tline = fgetl(fid_r);
    end
    tline = fgetl(fid_r); %this line is for oder etc
    %now start to collect data
    %now we have each row
    FeaturesIndices =[];
    Scores = [];
     tline = fgetl(fid_r);%first line
    while length(tline)> 1 && ~feof(fid_r)
        
        components = strsplit(tline);
        FeaturesIndices = [FeaturesIndices, str2num(components{2})];
        Scores = [Scores, str2num(components{end})];
        tline = fgetl(fid_r);%get a line
    end
    fclose(fid_r);
end

%end of file