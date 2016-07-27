function SS = ssg_decorate(SS, SS2)
% SS = ssg_decorate(SS1, SS2)
% INPUT:
% SS1 : a state space (n1,...,nk)
% SS2 : a state space (m1,...,mk)
% OUTPUT:
% SS  : a state space (n1,...,nk,m1,...,mk)
% EXAMPLE:
% SS = ssg_closed_single(3,2)
% RR=ssg_renv(10)
% ssg_decorate(SS,RR)
%
% Copyright (c) 2012-2014, Imperial College London 
% All rights reserved.


if isempty(SS)
    SS = SS2;
    return
else if isempty(SS2)
    return
end

n1 = size(SS,1); m1 = size(SS,2);
n2 = size(SS2,1); m2 = size(SS2,2);
SS = repmat(SS, n2, 1);

curStates = 1:n1;
for s=1:n2    
    SS(curStates,(m1+1):(m1+m2)) = repmat(SS2(s,:),length(curStates),1);
    curStates = (curStates) + n1;
end

end