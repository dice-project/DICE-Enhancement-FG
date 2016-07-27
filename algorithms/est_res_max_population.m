function maxPop = est_res_max_population(metric,flags,dicefg_disp)
% EST_RES_MAX_POPULATION Estimate maximum number of jobs seen at the
% resource.
%
% Copyright (c) 2012-2016, Imperial College London
% All rights reserved.
% This code is released under the 3-Clause BSD License.

numClasses = length(metric.ResClassList);
maxPop = zeros(1,numClasses);

for r=1:length(metric.ResClassList)
    arvT=metric.ResData{hash_metric('arvT'),hash_data(metric, metric.ResIndex, r)};
    depT=metric.ResData{hash_metric('depT'),hash_data(metric, metric.ResIndex, r)};    
    state=[ arvT,  ones(size(arvT));
        depT, -ones(size(depT))];
    state=sortrows(state,1);
    maxPop(r)=max(cumsum(state(:,2)));
end
end