function [resDataDep,graphDataDep] = est_ubr_dependencies(metric)
% [resDataDep,graphDataDep] = EST_UBR_DEPENDENCIES(data, resource, class)
% Returns data dependency matrix for est-ubr

resDataDep = zeros(size(metric.resdata));
resourceIdx = find(cellfun(@(x) strcmp(metric.ResourceName,x),metric.resources));

% require aggregate utilization at resource
resDataDep(hash_metric('util'),hash_data(metric,resourceIdx,0))=1;
for r=1:length(metric.resclasses)    
    % require mean throughput for each class, except aggr
    resDataDep(hash_metric('tputAvg'),hash_data(metric,resourceIdx,r))=1;
end

graphDataDep = zeros(size(metric.graphdata));

end