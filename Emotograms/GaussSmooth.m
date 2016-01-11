%written by John and Saria(saria et al.)
%modified and commented by Yuan Shangguan
%function [smoothedTS] = GaussSmooth(ts,sd)
% takes in ts: time series data as a row of input stats
% sd: the standard deviation of gaussian smoothing noise. 
% this function smooths the data by taking the data as the weighted sum of
%   its value and its neighborhood points. The number of neighborhood
%   ponits and the weights are defined by a normal distribution with sd.,
%   tolerance tol, which is by default defined as tol=0.1


function [smoothedTS] = GaussSmooth(ts,sd, tol)
if ~exist('peakThreshold','var') || tol < 0
    tol =.1;
end

for i = 1:20 %left and right 1 to 20, looking at whether this many will have
    %significant impact 
    if(normpdf(i,0,sd)<=tol||i==20)
       width = 1+i*2; 
       break;
    end
end
lower = -width/2+.5;   %lower is -i
pos = lower:(lower+width-1);   %positions are -i : i
probs = normpdf(pos,0,sd);  %probabilities of the points around the center due to normal distribution
dev = (width-1)/2; %dev is i
mid = (width+1)/2; %mid = i +1
smoothedTS = zeros(size(ts));
for t = 1:length(ts)
   lower =  max([1 t-dev]);  
   upper = min([length(ts) t+dev]);
   above = upper-t;
   below = t-lower;
   smoothedTS(t) = sum(ts(lower:upper).*probs((mid-below):(mid+above)))/...
       sum(probs((mid-below):(mid+above)));
end

end