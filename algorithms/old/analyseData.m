function [prob_nbCustomer, N, N0] = analyseData( data, nbJobs, nbClasses, nbNodes, data_needed)

%number of customer classes, start from 1.
K = nbClasses; 

%total number of jobs in the system
N = nbJobs;
N0 = zeros(1,K);

tempTS=[];
tempClass=[];
tempLogger=[];
for i = 1:K
    temp_length = size(data{3,i},1);
    tempTS = [tempTS;data{3,i};data{3,i}+data{4,i}*1000];
    tempClass = [tempClass;ones(temp_length*2,1)*i];
    tempLogger = [tempLogger;ones(temp_length,1);ones(temp_length,1)*2];
end

[ts index] = sort(tempTS);
class_id = tempClass(index);
logger_id = tempLogger(index);

burnin = length(ts)-data_needed;

if burnin < 0 || data_needed == 0
    burnin = 1;
end

%Initialise
total_length = length(ts);
count = zeros(total_length,K,nbNodes); %number of customers in the queue, start from time 0
count(1,:,1) = N; %initialise delay center with N jobs

% serial
for i = 1:total_length-1
    count(i+1,:,:) = count(i,:,:);
    count(i+1,:,:) = count(i,:,:);

    count(i+1,class_id(i),logger_id(i)) = count(i,class_id(i),logger_id(i))-1;
    
    if logger_id(i) == nbNodes
        count(i+1,class_id(i),1) = count(i,class_id(i),1)+1;
    else
        count(i+1,class_id(i),logger_id(i)+1) = count(i,class_id(i),logger_id(i)+1)+1;
    end
end

if sum(N) == 0
    for i = 1:K
        N(i) = max(max(count(:,i,:)));
    end
end

for i = 1:total_length
    for j = 1:K
        count(i,j,1) = count(i,j,1) + N(j);
    end
end


% parallel
% for i = 1:total_length-1
%     count(i+1,:,:) = count(i,:,:);
%     
%     if logger_id(i) < 5
%         count(i+1,class_id(i),1) = count(i,class_id(i),1)-1;
%         count(i+1,class_id(i),logger_id(i)+1) = count(i,class_id(i),logger_id(i)+1)+1;
%     end
%     
%     if logger_id(i) > 5
%         count(i+1,class_id(i),1) = count(i,class_id(i),1)+1;
%         count(i+1,class_id(i),logger_id(i)-9) = count(i,class_id(i),logger_id(i)-9)-1;
%     end
%     
% end

count = reshape(count,total_length,nbClasses*nbNodes);

%calculate the interval between each timestamp
%time_interval(1) = ts(1);
time_interval(1) = 0;
time_interval(2:total_length) = diff(ts); 

count(:,end+1) = time_interval';
count = count(burnin:end,:);

count = sortrows(count,[1:size(count,2)-1]);

[C ia ic] = unique(count(:,1:end-1),'rows','legacy');

%the first one
Time = C;
Time(1,end+1) = sum(count(1:ia(1),end));
for i =2:size(C,1)
    Time(i,end) = sum(count(ia(i-1)+1:ia(i),end));
end

%observed time period
obs_length = ts(end)-ts(burnin);
%calculate the probability
prob_nbCustomer = Time;
prob_nbCustomer(:,end) = prob_nbCustomer(:,end)/obs_length;

for i = 1:K
    N0(i) = sum(prob_nbCustomer(:,end).*prob_nbCustomer(:,K+i));
end
end