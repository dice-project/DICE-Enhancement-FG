function demEst = est_res_ubr(metric, flags, dicefg_disp)
% UBR Utilization-based regression.
%
% Copyright (c) 2012-2016, Imperial College London
% All rights reserved.
% This code is released under the 3-Clause BSD License.

if nargin < 3
    dicefg_disp = @dicefg_disp_silent;
end

nServers = flags.numServers;
cpuUtil = get_data(metric,'util', metric.ResIndex, 0);

% determine probability of each sampling period
for r=1:metric.NumClasses
    % obtain average throughput samples
    avgTput{r} = get_data(metric,'tputAvg', metric.ResIndex, r);
end

cpuUtil = cpuUtil * nServers;
demEst = lsqnonneg(cell2mat(avgTput), cpuUtil);
end
