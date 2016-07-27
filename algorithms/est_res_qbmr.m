function demEst = est_qbmr(memUsage, qlenAvg, dicefg_disp)
% QBMR Queue-based memory regression.  
%
% Copyright (c) 2012-2016, Imperial College London 
% All rights reserved.
% This code is released under the 3-Clause BSD License. 

% nanSet = isnan(memUsage);
% if sum(nanSet) > 0 
%     dicefg_disp(2,'Filtering out NaN values found for memory usage.');
%     memUsage = memUsage(nanSet == 0);
%     qlenAvg = qlenAvg(nanSet == 0,:);
% end

demEst = lsqnonneg(qlenAvg, memUsage);
end
