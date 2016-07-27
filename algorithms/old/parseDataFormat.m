function [sampInt, cpuUtil, arrTimes, respTimes, avgRespTimes, avgTput]=parseDataFormat(data) 
% PARSEDATAFORMAT Translates a common data format and returns the individual 
% variables 
%
% [A,B,C,D,E,F] = PARSEDATAFORMAT(H) translates the input data H in the common
% data format and returns: 
% A: final timestamps of the sampling intervals (s)
% B: average CPU utilization on each sampling interval
% C: timestamps of request arrivals (s)
% D: response times of each request (s) 
% E: average response times as observed in each sampling interval (s)
% F: average throughput in each sampling interval (1/s)
% 
% 
% Copyright (c) 2012-2013, Imperial College London 
% All rights reserved.


% Final timestamps of the sampling intervals - (ms) to (s) 
sampInt=[0;data{1,end}/1000]; 

% Average CPU utilization on each sampling interval
cpuUtil=data{2,end};

% Timestamps of request arrivals (ms) to (s)
arrTimes={data{3,1:(end-1)}};
for i=1:size(arrTimes,2) 
    arrTimes{:,i}=arrTimes{:,i}/1000; 
end

% Response times of each request (s) 
respTimes={data{4,1:(end-1)}};

% Average response times as observed in each sampling interval (s)
avgRespTimes=cell2mat({data{5,1:(end-1)}});

% average throughput in each sampling interval (1/s)
avgTput=cell2mat({data{6,1:(end-1)}});

end