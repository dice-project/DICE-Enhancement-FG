function [resDataDep,sysDataDep] = est_ubr_dependencies(metric)
% [resDataDep,sysDataDep] = EST_UBR_DEPENDENCIES(data, resource, class)
% Returns data dependency matrix for est-ubr

resDataDep = zeros(size(metric.ResData));
resourceIdx = find(cellfun(@(x) strcmp(metric.AnalyzeResource,x),metric.ResList));

% require aggregate utilization at resource
resDataDep(hash_metric('util'),hash_data(metric,resourceIdx,0))=1;
for r=1:length(metric.ResClassList)    
    % require mean throughput for each class, except aggr
    resDataDep(hash_metric('tputAvg'),hash_data(metric,resourceIdx,r))=1;
end

sysDataDep = zeros(size(metric.SysData));

end