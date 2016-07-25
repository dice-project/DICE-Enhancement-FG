function extDelay = est_res_extdelay(cpuUtil, avgTput, nServers,dicefg_disp)
% EST_SYS_EXTDELAY Estimate external delay (think time, inter-arrival time)
% seen locally at the resource.  
%
% Copyright (c) 2012-2016, Imperial College London 
% All rights reserved.
% This code is released under the 3-Clause BSD License. 

nbClasses = size(data,2)-1;
think_time = zeros(1,nbClasses);
for k = 1:nbClasses
    think_time(k) = N0(k)/mean(data{6,k});
    R(k) = mean(data{5,k});
    X(k) = mean(data{6,k});
end

end

