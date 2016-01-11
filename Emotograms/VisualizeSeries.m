
wwss = {'0.25','0.125','0.5','1','2', 'Inf'};
window_size ='0.25';
Aemotions = {'h','a','sa','n','d','f','su'};
speakers = {'DC','JE','JK','KL'};
AudioVisualFolder = {'AudioVisual', 'Audio', 'Visual'};

fileType = 1;
actors  = 1;
emotions = 2; % happy dimension

trainf_out = [AudioVisualFolder{fileType},'/Series/Corr_TimeSeries_leave',speakers{actors},'train_emotion',num2str(emotions),'.txt'];
% test_out = [AudioVisualFolder{fileType},'/Series/Corr_TimeSeries_leave',speakers{actors},'test_emotion',num2str(emotions),'.txt'];
colors = {'m','b','c','k','c','g','r'};

fid = fopen(trainf_out,'r');
figure;color = 1;
while ~feof(fid)
    tline = fgetl(fid);
    comp = strsplit(tline,',');
    emo = str2num(comp{1});
    series = [];
    for ii = 2:length(comp)
        series = [series, str2num(comp{ii})];
    end
    [series] = GaussSmooth(series, 1, 0.5);
    subplot(3,3,emo);
    title(['Emotion is ',Aemotions{emo}]);
    plot(1:length(series),series,[colors{emo},'*-']);
    hold on;
    pause(0.02);
    color = color +1;
end
hold off;
fclose(fid);