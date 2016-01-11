function [final_features ,final_mark] = SMOTE(original_features, original_mark,N,K)
%%--------------------
% modified by Juneysg@umich.edu
% original code by 	Monther Alhamdoosh	 
% from http://www.mathworks.com/matlabcentral/fileexchange/38830-smote--synthetic-minority-over-sampling-technique-
% changes:
    % added in N and K 
    % N is the multiple size that we wish to increase the positive
    %   N == 2 means we want the positive space to increase by 2 times
    % instances to
    % K is the number of nearest neighbors
% SMOTE algorithm see http://www.cs.cmu.edu/afs/cs/project/jair/pub/volume16/chawla02a-html/node6.html
%%---------------------
    

%% condition check
if N > K % if we have 
    K  = N;
end

if K > size(original_features,1)
    K = size(original_features,1);
end


%% process feature for nearest neighbor
%index of the positives (to be smoted.
ind = find(original_mark == 1);

% P = candidate points
P = original_features(ind,:);
T = P';% Complete Feature Vector

% Finding the 5 positive nearest neighbours of all the positive blobs
I = nearestneighbour(T, T, 'NumberOfNeighbours', K);
% I is now index K*points
I = I';

[r c] = size(I); %r is the number of points in X, c is the number of neighbors
S = zeros((N-1)*r,size(P,2));


%% randomize the selection of K nearest neighbors and the ratio of addition between them
ii = 1;
for i=1:r
    for kk = 1:N-1 %each positive label, we increase the size by N-1
    	j = randi(K);
        th = rand;
        index = I(i,j);
        new_P=(1-th).*P(i,:) + th.*P(index,:);
        S(ii,:) = new_P;
        ii = ii+1;
    end
end

%% change the marks too
original_features = [original_features;S];
[r c] = size(S);
mark = ones(r,1);
original_mark = [original_mark;mark];

final_features = original_features;
final_mark = original_mark;
% %% Final check which ones to include
% train_incl = ones(length(original_mark), 1);

% I = nearestneighbour(original_features', original_features', 'NumberOfNeighbours', K);
% I = I';

% for j = 1:length(original_mark)
%     len = length(find(original_mark(I(j, 2:K)) ~= original_mark(j,1)));
%     if(len >= K-2)
%         if(original_mark(j,1) == 1)
%          train_incl(original_mark(I(j, 2:4)) ~= original_mark(j,1),1) = 0;
%         else
%          train_incl(j,1) = 0;   
%         end    
%     end
% end
% final_features = original_features(train_incl == 1, :);
% final_mark = original_mark(train_incl == 1, :);

% %%% Reverse K-NN
% 
% mitosis_features = new_feature_mat;
% mitosis_mark= new_mark;
% 
% % P = candidate points
% P = mitosis_features;
% T = P';
% 
% % X = Complete Feature Vector
% X = T;
% 
% % Finding the 5 positive nearest neighbours of all the positive blobs
% I = nearestneighbour(T, X, 'NumberOfNeighbours', 4);
% 
% I = I';
% len = length(new_mark);
% incl_blob = ones(len,1);
% total=[];
% for i=1:len
%     total = length(find(I(:,2:4)==i));
%     if(total <= 1)
%         incl_blob(i,1) = 0;
%     end
% end
% 
% final_mark = new_mark(find(incl_blob == 1));
% final_features = mitosis_features(find(incl_blob == 1),:);
% 
% 
% 
% 
% %%%
% 
% % % Updating the SVM file
% % [r c] = size(new_feature_mat);
% % fp = fopen('SVMtrainNew.txt', 'w');
% % for i = 1:r
% %     fprintf(fp, '%d ',new_mark(i,1));
% %     for j = 1:c
% %     
% %        fprintf(fp, '%d:%d ', j, new_feature_mat(i,j));     
% %     
% %     end
% %     fprintf(fp, '\n');
% % end
% % fclose('all');
% % 
% % new_mark = new_mark';
% % % Updating the Neural Network file
% % 
% % 
% % % save('NURtrainNew.mat','new_feature_mat');
% % % save('NURmarkNew.mat','new_mark');
% % 
% % mitosis_features = new_feature_mat;
% % mitosis_mark= new_mark';
% % % save('NURtrain.mat','mitosis_features');
% % % save('NURmark.mat','mitosis_mark');
% % 
end


%% end of file