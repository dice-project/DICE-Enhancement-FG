function maxPop = est_res_maxavg_population(metric,flags,dicefg_disp)
% EST_RES_MAX_POPULATION Estimate maximum number of jobs seen at the
% resource.
%
% Copyright (c) 2012-2016, Imperial College London
% All rights reserved.
% This code is released under the 3-Clause BSD License.

numClasses = metric.NumClasses;
maxPop = zeros(1,numClasses);

for r=1:metric.NumClasses    
    qlenAvg = get_data(metric,'qlenAvg', metric.ResIndex, r);    
    maxPop(r)=max(qlenAvg);
end
end