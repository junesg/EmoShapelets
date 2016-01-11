function [AUDat , AUlabel]= FromPointsToAU(data, true_labels)
	ALists = {'RBRO1', 'LBRO1' , 'RBRO4', 'LBRO4', ...
	'RC5',  'RC7', 'RC1',  'RC3',    'RC8', 'RBRO3','RBRO2',...
	'LC5',  'LC7', 'LC1',  'LC3',    'LC8', 'LBRO3','LBRO2',...
	'Mou2','Mou3','Mou4','Mou1','Mou1','Mou5',...
	'RLID','LLID','RC6','LC6','FH1','FH2','FH3','MH','RNSTRL','LNSTRL',...
	'TNOSE','TNOSE','CH2','TNOSE','TNOSE'};
	BLists = {'MH',    'MH'    , 'RC3'  , 'LC3',   ...
	'TNOSE', 'RC1', 'Mou1', 'RBM3',  'RBRO1','RC7', 'RC7',...
	'TNOSE', 'LC1', 'Mou5', 'LBM3',  'LBRO1','LC7', 'LC7',...
	'Mou8','Mou7','Mou6','Mou5','TNOSE','TNOSE',...
	'MH','MH','TNOSE','TNOSE','FH2','FH3','FH1','FH2','MNOSE','MNOSE',...
	'Mou3','Mou7','Mou7','RC4','LC4'};

	AngList1 = {'MH','MH','Mou1','Mou5', 'MH','MH','TNOSE','TNOSE',...
		'MH','MH','TNOSE','TNOSE','FH1','LC6','RC6',...
		 'RBM3','RBM3','LBM3','LBM3','Mou2'};
	AngList2 = {'RBRO1','LBRO1','RC1','LC1','RBRO4','LBRO4','Mou1','Mou5',...
		'RLID','LLID','RC5','LC5','FH2','LC5','RC5',...
		'RBM2','RBM1','LBM2','LBM1','CH2'};
	AngList3 = {'MNOSE','MNOSE','CH1','CH3','RC3','RC3','CH2','CH2',...
		'MNOSE','MNOSE','RC3','LC3','FH3','LC4','RC4',...
		'RBM0','RBM0','LBM0','LBM0','Mou4'};

	AUDat = []; AUlabel = true_labels;
		%original position data 
		AUDat(:,1:size(data,2)) = data;
        
		for distIter = 1:length(ALists)
			AUDat(:,end+1) = getDist(ALists{distIter},BLists{distIter},true_labels,data);
            AUlabel = [AUlabel,',','dist(',ALists{distIter},'-',BLists{distIter},')'];
		end
		for angIter = 1:length(AngList3)
			AUDat(:,end+1) = getAng(AngList1{angIter},AngList2{angIter},AngList3{angIter},true_labels,data);
            AUlabel = [AUlabel,',','ang',AngList1{angIter},'>',AngList2{angIter},'<',AngList3{angIter}];
        end
end



function AUDist = getDist(a,b, true_labels, data)
	% a and b are labels to the two ends of the  distances
	aInd  = findLabel(a, true_labels);
	bInd = findLabel(b, true_labels);
	AUDist = sqrt(sum((data(:,aInd) - data(:,bInd)).^2,2));
end

function Angle = getAng(a,b,c,true_labels,data)
	% b is the center label point of the angle
	aInd = findLabel(a, true_labels);
	bInd = findLabel(b, true_labels);
	cInd = findLabel(c, true_labels);
	vec1 = data(:,aInd) - data(:,bInd);
	vec2 = data(:,cInd) - data(:,bInd);
	Angle = acos( dot(vec1,vec2,2)./ sqrt(sum(vec1.^2,2))./sqrt(sum(vec2.^2,2)));
end


function threeInd = findLabel(aLabel, true_labels)
	comp = strsplit(true_labels,',');
	threeInd = [];
	for jj = 1:length(comp)
		subComp = strsplit(comp{jj},'_');
		if strcmp(subComp{1}, aLabel) ==1
			threeInd = [threeInd, jj];
		end
	end
	if length(threeInd) ~= 3
		error([ aLabel, ' has more than one data?',num2str(threeInd),' data\n']);
	end
end


%% end of file