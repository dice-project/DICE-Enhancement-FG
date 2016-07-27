function extDelay = est_res_extdelay(metric,flags,dicefg_disp)
% EST_RES_EXTDELAY Estimate average external delay (think time) seen
% locally at the resource.  The resource is assumed to be in a closed loop
% with a delay node.
%
% Copyright (c) 2012-2016, Imperial College London
% All rights reserved.
% This code is released under the 3-Clause BSD License.

numClasses = length(metric.ResClassList);
extDelay = zeros(1,numClasses);

flag.AssumeMaxPopulation=1;
if flag.AssumeMaxPopulation
    % approximating the job population with the maximum concurrency level seen
    % at the resource in each class
    jobPop = est_res_max_population(metric,flags,dicefg_disp);
%elseif flag.AssumeMaxAvgPopulation
    % approximating the job population with the maximal sample of the
    % average concurrency level at the resource seen at sample periods
%    jobPop = est_res_maxavg_population(metric,flags,dicefg_disp);
end
% validation: jobPop=[10,20] -> exact extdelay=[80,20]

% determine probability of each sampling period
weightsTS = diff(cell2mat({metric.ResData{hash_metric('ts'),hash_data(metric, metric.ResIndex, 1:length(metric.ResClassList))}}),1);
weightsTS = weightsTS./repmat(sum(weightsTS,1),size(weightsTS,1),1);

% obtain overall average by weighted sum of the avg tput and avg rt samples
avgTput = sum(weightsTS.*cell2mat({metric.ResData{hash_metric('tputAvg'),hash_data(metric, metric.ResIndex, 1:length(metric.ResClassList))}}),1);
avgRt = sum(weightsTS.*cell2mat({metric.ResData{hash_metric('respTAvg'),hash_data(metric, metric.ResIndex, 1:length(metric.ResClassList))}}),1);

% Little's law: N_s=X_s(R_s+Z_s) => Z_s=N_s/X_s-R_s
for s = 1:numClasses
    extDelay(s) = jobPop(s)/avgTput(s)-avgRt(s);
end
end

