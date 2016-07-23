function [ nbJobs, N0] = estimateN( data )

nbClasses = size(data,2)-1;
nbNodes = 2;
nbJobs = zeros(1,nbClasses);

[~, nbJobs, N0] = analyseData(data, nbJobs, nbClasses, nbNodes, 0);


end

