function demandEst = des_RPS(rt,class,ql,nCores)
% DES_RPS implements the RPS demand estimation method
% RT:       response times samples. 
%           column vector with all response time samples  
% CLASS:    class of the request samples
%           column vector with the class of each sample
% QL:       queue length samples
%           matrix with R columns containing the number of jobs 
%           of each class observed by each sample
% NCORES:   number of cores
%
% Copyright (c) 2012-2014, Imperial College London 
% All rights reserved.

R = max(class);
% put samples in ERPS format
rTimes = cell(1,R);
aQueue = cell(1,R);
for r = 1:R
    rTimes{r} = rt(class==r); 
    aQueue{r} = ql(class==r,:); 
end

demandEst = zeros(1,R); 

% regression analysis to estimate mean demands 
for r=1:R
    respTimes = rTimes{1,r};
    totalQL = sum(aQueue{1,r},2)/nCores;
    demandEst(r) = lsqnonneg(totalQL,respTimes)';
end

end