function maxPop = est_res_max_population(metric,flags,dicefg_disp)
% EST_RES_MAX_POPULATION Estimate maximum number of jobs seen at the
% resource.
%
% Copyright (c) 2012-2016, Imperial College London
% All rights reserved.
% This code is released under the 3-Clause BSD License.

numClasses = metric.NumClasses;
maxPop = zeros(1,numClasses);

for r=1:metric.NumClasses    
    arvT = get_data(metric,'arvT', metric.ResIndex, r);
    respT = get_data(metric,'respT', metric.ResIndex, r);    
    depT=arvT+respT;
    state=[ arvT,  ones(size(arvT));
        depT, -ones(size(depT))];
    state=sortrows(state,1);
    maxPop(r)=max(cumsum(state(:,2)));
end
end