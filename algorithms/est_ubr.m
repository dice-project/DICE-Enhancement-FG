function demEst = est_ubr(cpuUtil, avgTput, nServers,dicefg_disp)
% UBR Utilization-based regression.  
%
% Copyright (c) 2012-2016, Imperial College London 
% All rights reserved.
% This code is released under the 3-Clause BSD License. 

nanSet = isnan(cpuUtil);
if sum(nanSet) > 0 
    dicefg_disp(2,'NaN values found for CPU Utilization. Removing NaN values.');
    cpuUtil = cpuUtil(nanSet == 0);
    avgTput = avgTput(nanSet == 0,:);
end

cpuUtil = cpuUtil * nServers;
demEst = lsqnonneg(avgTput, cpuUtil);
end
