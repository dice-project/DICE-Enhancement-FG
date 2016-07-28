function memDem = est_res_qbmr(metric, flags, dicefg_disp)
% QBMR Queue-based memory regression.  
%
% Copyright (c) 2012-2016, Imperial College London 
% All rights reserved.
% This code is released under the 3-Clause BSD License. 

nServers = flags.numServers;
memUsage = get_data(metric,'mem', metric.ResIndex, 0);

% determine probability of each sampling period
for r=1:metric.NumClasses
    % obtain average throughput samples
    qlenAvg{r} = get_data(metric,'qlenAvg', metric.ResIndex, r);
end

memDem = lsqnonneg(cell2mat(qlenAvg), memUsage);
end
