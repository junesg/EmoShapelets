

function GatherAllFiles()
cdd = pwd;

file = fopen('~/google_drive/IEMOCAP_full_release/Code/MocapFeatureExtract/AllMocap.csv','w');

for ss = 1:5 %loop through each session
pth1 = ['~/google_drive/IEMOCAP_full_release/Session',num2str(ss),'/sentences/MOCAP_rotated'];
pth2 = ['~/google_drive/IEMOCAP_full_release/Session',num2str(ss),'/sentences/MOCAP_head'];

cd(pth1);
curDir = pwd;
folders = dir(pwd);
fprintf(file,'FileName, Session, Speaker, Condition, Sentence, PathRotate, PathHead\n');


for pid = 1:length(folders)
    if folders(pid).name(1) == '.', continue;end
    cd (folders(pid).name);
    files = dir(pwd);
    
    for fidt = 1:length(files)
        if files(fidt).name(1) == '.', continue;end
            comp = strsplit(files(fidt).name,'_');
            fn = [files(fidt).name]; % a string
            sess = ss; % a numer
            speaker = comp{1}(end); %a string
            Condition = comp{2};
            Sentence = comp{end}(1:end-4);
            Path = [pwd,'/',fn];
            Path2 = [pth2,'/',folders(pid).name,'/',files(fidt).name];
            if exist(Path) == 2 && exist(Path2) ==2
                fprintf(file,'%s, %d,%s,%s,%s,%s,%s\n',fn, sess, speaker, Condition, Sentence,Path, Path2);
            end
    end
	cd ..
end
cd (curDir);
end

fclose(file);
cd (cdd);


end


%% end of file
