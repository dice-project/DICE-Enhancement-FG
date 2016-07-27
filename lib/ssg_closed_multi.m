function SS = ssg_closed_multi(M, N)
% Copyright (c) 2012-2016, Imperial College London 
% All rights reserved.

R = length(N);
SS = ssg_closed_single(M, N(1));
for r = 2:R
    SS = ssg_decorate(SS, ssg_closed_single(M, N(r)));
end
end