function [resDataDep,sysDataDep] = est_res_qbmr_dependencies(metric)
% [resDataDep,sysDataDep] = EST_QMEM_DEPENDENCIES(data, resource, class)
% Returns data dependency matrix for est-qmem

resDataDep = zeros(size(metric.ResData));
for r=1:metric.NumClasses
    % require average queue-length for each class at each resource, except aggr
    resDataDep(hash_metric('qlenAvg'),hash_data(metric,metric.ResIndex,r)) = 1;
end
resDataDep(hash_metric('memAvg'),hash_data(metric,metric.ResIndex,0)) = 1;

sysDataDep = zeros(size(metric.SysData));

end