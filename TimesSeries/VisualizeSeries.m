
for overallEmo  = 1:4
Colors = {'b','r','k','g'};

figure

content = dlmread(['TimeSeries_leave3test_noAngle_emotion',num2str(overallEmo),'.txt'],',');
emotions = {'Happy','Angry','Sad','Neutral'};


    title(emotions{2});
for ii  = 1:size(content,1)

    emo = content(ii,1);
    data = content(ii,2:end);
    [data] = GaussSmooth(data,20,1);
    
   subplot(2,2,emo)
        plot( 1:length(data), (data),Colors{overallEmo});
        title([emotions{overallEmo},' shown in ',emotions{emo},' class']);
        axis([0,150,0,1]);
        hold on;
        pause;
        
  
end

end


    content1 = dlmread(['TimeSeries_leave3test_noAngle_emotion',num2str(1),'.txt'],',');
    content2 = dlmread(['TimeSeries_leave3test_noAngle_emotion',num2str(2),'.txt'],',');
        content3 = dlmread(['TimeSeries_leave3test_noAngle_emotion',num2str(3),'.txt'],',');
            content4 = dlmread(['TimeSeries_leave3test_noAngle_emotion',num2str(4),'.txt'],',');
            
            
            rr = 20;
            col = 1:35
            content1(rr,col) = GaussSmooth(content1(rr,col),20,1);
            content2(rr,col) = GaussSmooth(content2(rr,col),20,1);
            content3(rr,col) = GaussSmooth(content3(rr,col),20,1);
            content4(rr,col) = GaussSmooth(content4(rr,col),20,1);

            plot( (1:length(content1(rr,col))).*0.125, content1(rr,col),...
                (1:length(content1(rr,col))).*0.125, content2(rr,col),...
               (1:length(content1(rr,col))).*0.125, content3(rr,col),...
                (1:length(content1(rr,col))).*0.125, content4(rr,col));
            legend('Happy','Angry','Sad','Neutral');
            title('Emotogram time series in an example utterance');
            xlabel('Time/s');
            ylabel('Emotogram (estimates of emotion in that utterance, normalized)');