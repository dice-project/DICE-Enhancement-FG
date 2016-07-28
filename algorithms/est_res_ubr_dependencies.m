function [resDataDep,sysDataDep] = est_res_ubr_dependencies(metric)
% [resDataDep,sysDataDep] = EST_UBR_DEPENDENCIES(data, resource, class)
% Returns data dependency matrix for est-ubr

resDataDep = zeros(size(metric.ResData));

% require aggregate utilization at resource
resDataDep(hash_metric('util'),hash_data(metric,metric.ResIndex,0))=1;
for r=1:length(metric.ResClassList)    
    % require mean throughput for each class, except aggr
    resDataDep(hash_metric('tputAvg'),hash_data(metric,metric.ResIndex,r))=1;
end

sysDataDep = zeros(size(metric.SysData));

end