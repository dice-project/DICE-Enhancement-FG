function demEst = est_ubr(metric, flags, dicefg_disp)
% UBR Utilization-based regression.
%
% Copyright (c) 2012-2016, Imperial College London
% All rights reserved.
% This code is released under the 3-Clause BSD License.

cpuUtil = metric.ResData{hash_metric('util'),hash_data(metric, metric.ResIndex, 0)}(:);
avgTput = cell2mat({metric.ResData{hash_metric('tputAvg'),hash_data(metric, metric.ResIndex, 1:length(metric.ResClassList))}});
nServers = flags.numServers;

nanSet = isnan(cpuUtil);
if sum(nanSet) > 0
    dicefg_disp(2,'NaN values found for CPU Utilization. Removing NaN values.');
    cpuUtil = cpuUtil(nanSet == 0);
    avgTput = avgTput(nanSet == 0,:);
end

cpuUtil = cpuUtil * nServers;
demEst = lsqnonneg(avgTput, cpuUtil);
end
