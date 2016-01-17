

function generateAudioFiles()
cdd = pwd;

file = fopen('~/google_drive/IEMOCAP_full_release/AudioFeatureExtract/AllWavFiles.csv','w');

for ss = 1:5 %loop through each session
pth = ['~/google_drive/IEMOCAP_full_release/Session',num2str(ss),'/sentences/wav'];
cd(pth);
curDir = pwd;
folders = dir(pwd);
fprintf(file,'FileName,Session, Speaker, Condition, Sentence, Path\n');


for pid = 1:length(folders)
    if folders(pid).name(1) == '.', continue;end
    cd (folders(pid).name);
    files = dir(pwd);
    
    for fidt = 1:length(files)
        if files(fidt).name(1) == '.', continue;end
            comp = strsplit(files(fidt).name,'_');
            fn = files(fidt).name; % a string
            sess = ss; % a numer
            speaker = comp{1}(end); %a string
            Condition = comp{2};
            Sentence = comp{end}(1:end-4);
            Path = [pwd,'/', fn];
            fprintf(file,'%s, %d,%s,%s,%s,%s\n',fn, sess, speaker, Condition, Sentence,Path);
    end
	cd ..
end
cd (curDir);
end

fclose(file);
cd (cdd);


end


%% end of file
