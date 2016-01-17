
load('UtteranceRatings.mat');

for threshold = 1:3



Majority = cell(0);
Non_Maj = cell(0);

PossibleEmotions = {'Happiness;','Neutral;', 'Anger;','Sadness;'};

for ii = 1:length(utterances)

    count = zeros(length(PossibleEmotions),1);
	for em = 1:length(utterances{ii}.Emotion) %loop through evaluators
		thisEval = utterances{ii}.Emotion{em};
        
        subcountHappy = 0;
		for eviter = 1:length(thisEval) %loop through his evaluations 
			thisEmo = utterances{ii}.Emotion{em}{eviter};
			%merge excitment with happiness
			if strcmp(thisEmo,'Excited;') == 1;
			 	thisEmo = 'Happiness;' ;
             end
            if (subcountHappy == 0 && strcmp(thisEmo,'Happiness;')==1) 
                count(find(strcmp(thisEmo, PossibleEmotions)==1)) =  count(find(strcmp(thisEmo, PossibleEmotions)==1))+1;
                subcountHappy =1;
            elseif strcmp(thisEmo,'Happiness;')~=1
                count(find(strcmp(thisEmo, PossibleEmotions)==1)) =  count(find(strcmp(thisEmo, PossibleEmotions)==1))+1;
            end
        end
    end
   

    if max(count)>3
        ii
        error('max >3')
    end

    inddd = find(count == threshold) ; %two out of three have reated this
    if threshold ==1,
        inddd = find(count >=2) ; %two out of three have reated this
    end
        
%     inddd = find(count  ==3) ; %three out of three have reated this
    
    %if length(inddd) >= 1
    if length(inddd) == 1
        Majority{end+1}.fileName = utterances{ii}.fileName;
        Majority{end}.Emotion = cell(0);
        for jjj = 1:length(inddd)
            Majority{end}.Emotion{end+1} = PossibleEmotions{inddd(jjj)};
        end
    elseif length(inddd)<1
		Non_Maj{end+1}.fileName = utterances{ii}.fileName;
    end

    
end







%% count -- analysis
Emotions = {'Happiness;','Anger;','Sadness;' ,'Neutral;'};
ccount = zeros(4,1);
for ii = 1:length(Majority)
    for jj = 1:4
        for kk = 1:length(Majority{ii}.Emotion)
           if strcmp( Majority{ii}.Emotion{kk}, Emotions{jj})==1
               ccount(jj) =  ccount(jj)+1;
           end
        end
    end
end

ccount



if threshold==2
save MajorityVote_NonPrototypic.mat
elseif threshold==3
save MajorityVote_Prototypic.mat 
else
save MajorityVote_Combined.mat     
end

end
%% end of file

