function meanST = est_ci(arvT,respT,nServers,warmUp,dicefg_disp)
% CI Complete Information estimation
%
% Configuration file fields:
% data:         the input data
% nServer:      number of servers on which the application is deployed
% warmUp:       number of jobs to be filtered out of the dataset
%
% Copyright (c) 2012-2016, Imperial College London
% All rights reserved.
% This code is released under the 3-Clause BSD License.

%other parameters
numExp = 1;
V = nServers;
K = size(respT,2) - 1;

Ddetail = cell(1,K);
sampleSize = size(respT{1},1);
for j = 2:K
    sampleSize = sampleSize + size(respT{j},1);
end
if warmUp < sampleSize
    sampleSize = sampleSize - warmUp;
else
    dicefg_disp(2,'Warm-up period specified longer than samples available. Terminating without running est-ci.');
    meanST = [];
    obs = [];
    return;
end

for k = 1:K
    times{k} = [arvT{k}/1000 respT{k}];
end

%compute departure times
for k = 1:K
    for i = 1:size(times{k},1)
        times{k}(i,3) = times{k}(i,1) + times{k}(i,2);
    end
end

%build array with all events
%first column: time
%second column: 0-arrival, 1-departure
%third column: class
%fourth column: arrival time (only for departures)
timesOrder = [];
for k = 1:K
    if size(times{k},2) > 2
        %arrivals
        timesOrder(end+1:end+size(times{k},1),:)=[times{k}(:,1) zeros(size(times{k},1),1) k*ones(size(times{k},1),1) zeros(size(times{k},1),1) ];
        %departures
        timesOrder(end+1:end+size(times{k},1),:)=[times{k}(:,3) ones(size(times{k},1),1) k*ones(size(times{k},1),1) times{k}(:,1)];
    end
end

%order events according to time of
timesOrder = sortrows(timesOrder,1);

%STATE
% each row corresponds to a current job
% first column:  the class of the job
% second column: the arrival time
% third column: the elapsed service time
state = [];

% time keeping
t = 0;
told = t;

%ACUM
% number of service completions observed for each class (row)
% and total service time per class (second column)
acum = zeros(K,2);
obs = cell(1,K); %holds all the service times observed

%advance until it has observed a total of warmUp requests
i = 1;
while sum(acum(:,1)) < warmUp
    t = timesOrder(i,1);
    telapsed = t - told;
    n = size(state,1);
    
    % add to each job in process the service time elapsed (divided
    % by the portion of the server actually dedicated to it in a PS server
    r = n;
    for j = 1:r
        state(j,3) = state(j,3) + telapsed/r;
    end
    
    %if the event is an arrival add the job to the state
    if timesOrder(i,2) == 0
        state(end+1,:) = [timesOrder(i,3) t 0 ];
    else
        %find job in progress that must leave
        k = 1; while state(k,2) ~= timesOrder(i,4); k = k+1; end
        %update stats
        acum(state(k,1),1) = acum(state(k,1),1) + 1;
        acum(state(k,1),2) = acum(state(k,1),2) + state(k,3);
        
        %update state
        state = state([1:k-1,k+1:end],:);
    end
    i = i + 1;
    told = t;
end

meanST = zeros(K,numExp);
for e = 1:numExp
    %actually sampled data
    acum = zeros(K,2);
    obs = cell(1,K); %holds all the service times observed
    while sum(acum(:,1)) < sampleSize %size(timesOrder,1)
        t = timesOrder(i,1);
        telapsed = t - told;
        n = size(state,1);
        
        % add to each job in process the service time elapsed (divided
        % by the portion of the server actually dedicated to it in a PS server
        %r = min(n,W);
        r = n;
        for j = 1:r
            if length(state(j,:)) <5
                state(j,4) = 0;
                %state(j,5) = 0;
            end
            if r <= V %at most as many jobs in service as processors
                state(j,3) = state(j,3) + telapsed;
                state(j,4) = state(j,4) + telapsed*r;
            else %more jobs in service than processors
                state(j,3) = state(j,3) + telapsed*V/r;
                state(j,4) = state(j,4) + telapsed*V/r*r;
            end
        end
        
        %if the event is an arrival add the job to the state
        if timesOrder(i,2) == 0
            state(end+1,:) = [timesOrder(i,3) t 0 0 0];
        else
            %find job in progress that must leave
            k = 1; while state(k,2) ~= timesOrder(i,4); k = k+1; end
            %update stats
            acum(state(k,1),1) = acum(state(k,1),1) + 1;
            acum(state(k,1),2) = acum(state(k,1),2) + state(k,3);
            obs{state(k,1)}(end+1) = state(k,3);
            %update state
            
            temp = state(k,:);
            temp(4) = temp(4)/temp(3);
            state = state([1:k-1,k+1:end],:);
        end
        i = i+1;
        told = t;
    end
    meanST(:,e) = acum(:,2)./acum(:,1);
end

end