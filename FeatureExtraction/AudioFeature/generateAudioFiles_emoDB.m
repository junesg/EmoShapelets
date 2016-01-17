

function generateAudioFiles()
curDir = pwd;

pth = '~/google_drive/EmoDB/wav/';

Emotions = {'F', 'W', 'T', 'N', 'E', 'A', 'L' };


%% now get each file name
file = fopen('EmoDBAudioSummary.csv','w');
fprintf(file,'FileName, Speaker, Emotion, Sentence, Path\n');

allf = dir(pth);
for jj = 1:length(allf)
	if allf(jj).name(1) == '.', continue; end
	lk = [pth,'/',allf(jj).name];
	cpm = strsplit(allf(jj).name,'.');
	cpm = cpm{1}
    file_name = cpm;
    speaker = cpm(1:2);
    sentence = cpm(3:5);
    emotion = 0;
    for emo_ind = 1:length(Emotions)
        if Emotions{emo_ind} == cpm(6)
            emotion = emo_ind;
        end
    end
    assert(emotion ~= 0);
    ver_cmp = cpm(7);

	fprintf(file,'%s, %s, %s, %s, %s\n', allf(jj).name, speaker, num2str(emotion), sentence, lk);
end



fclose(file);

end
