function demandEst = main_ERPS(data, initSample, sampleSize, V)
% MAIN_ERPS setups the input data for the ERPS estimation method and calls it
%
% Copyright (c) 2012-2014, Imperial College London
% All rights reserved.

R = size(data,2) - 1;
sampleNumber = zeros(1,R+1);
for k = 1:R
    sampleNumber(k) = size(data{3,k},1);
end

% remove classes without samples
newR = sum(sampleNumber>0);
data2 = cell(6,newR+1);
r=1;
sampleNumber(R+1) = 1;
for k=1:R+1
    if sampleNumber(k)>0;
        for j=1:6
            data2{j,r} = data{j,k};
        end
        r=r+1;
    end
end
data = data2;
R = newR;
qls = getQLArrival(data);

rt = [];    % response times
class = []; % job classes
ql = [];    % queue lengths
at = [];    % arrival times
for k = 1:R
    rt = [rt; data{4,k}];
    class = [class; k*ones(size(data{4,k},1), 1)];
    ql = [ql; qls{k} ];
    at = [at; data{3,k}/1000];
end

allTimes = [at rt class ql];
allTimes = sortrows(allTimes,1);

at = allTimes(:,1);
rt = allTimes(:,2);
class = allTimes(:,3);
ql = allTimes(:,4:end);

if sampleSize == 0
    qlExp = ql(initSample:end,:);
    rtExp = rt(initSample:end);
    classExp = class(initSample:end);
else
    sampleSet = initSample:initSample+sampleSize-1;
    
    qlExp = ql(sampleSet,:);
    rtExp = rt(sampleSet);
    classExp = class(sampleSet);
end
numClassExp = hist(classExp,[1:R]);

rtzero = rtExp ==0;
if sum(rtzero)>0
    classExp = classExp(rtExp>0);
    qlExp = qlExp(rtExp>0,:);
    rtExp = rtExp(rtExp>0);
end

% run ERPS method
demandEst = des_ERPS(rtExp, classExp, qlExp, V);
