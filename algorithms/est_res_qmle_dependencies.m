function [resDataDep,sysDataDep] = est_res_qmle_dependencies(metric)
% [resDataDep,sysDataDep] = EST_RES_QMLE_DEPENDENCIES(data, resource, class)
% Returns data dependency matrix for est-qmle

resDataDep = zeros(size(metric.ResData));
for r=1:length(metric.ResClassList)
    % require average queue-length for each class at each resource, except aggr
    resDataDep(hash_metric('qlenAvg'),hash_data(metric,metric.ResIndex,r)) = 1;
    resDataDep(hash_metric('ts'),hash_data(metric,metric.ResIndex,r)) = 1;
end

sysDataDep = zeros(size(metric.SysData));

end