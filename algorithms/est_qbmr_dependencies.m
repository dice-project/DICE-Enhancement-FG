function [resDataDep,sysDataDep] = est_qbmr_dependencies(metric)
% [resDataDep,sysDataDep] = EST_QMEM_DEPENDENCIES(data, resource, class)
% Returns data dependency matrix for est-qmem

resDataDep = zeros(size(metric.resdata));
resourceIdx = find(cellfun(@(x) strcmp(metric.AnalyzeResource,x),metric.resources));
for r=1:length(metric.resclasses)
    % require average queue-length for each class at each resource, except aggr
    resDataDep(hash_metric('qlenAvg'),hash_data(metric,resourceIdx,r)) = 1;
end
resDataDep(hash_metric('memAvg'),hash_data(metric,resourceIdx,0)) = 1;

sysDataDep = zeros(size(metric.sysdata));

end