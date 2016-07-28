function [extDelay, jobPop] = est_res_extdelay(metric,flags,dicefg_disp)
% EST_RES_EXTDELAY Estimate average external delay (think time) seen
% locally at the resource.  The resource is assumed to be in a closed loop
% with a delay node.
%
% Copyright (c) 2012-2016, Imperial College London
% All rights reserved.
% This code is released under the 3-Clause BSD License.

numClasses = metric.NumClasses;
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
for r=1:metric.NumClasses
    weightTS{r} = diff(get_data(metric,'ts', metric.ResIndex, r),1);
    weightTS{r} = weightTS{r}./sum(weightTS{r});
    % obtain overall average by weighted sum of the avg tput and avg rt samples     
    avgTput(r) = sum(weightTS{r}.*get_data(metric,'tputAvg', metric.ResIndex, r),1);
    avgRt(r) = sum(weightTS{r}.*get_data(metric,'respTAvg', metric.ResIndex, r),1);
end

% Little's law: N_s=X_s(R_s+Z_s) => Z_s=N_s/X_s-R_s
for s = 1:numClasses
    extDelay(s) = jobPop(s)/avgTput(s)-avgRt(s);
end
end

