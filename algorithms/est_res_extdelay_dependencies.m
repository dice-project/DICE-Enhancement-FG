function [resDataDep,sysDataDep] = est_res_extdelay_dependencies(metric)
% [resDataDep,sysDataDep] = EST_EXTDELAY_DEPENDENCIES(data, resource, class)
% Returns data dependency matrix for est-ci

resDataDep = zeros(size(metric.ResData));
for r=1:metric.NumClasses
    resDataDep(hash_metric('ts'),hash_data(metric,metric.ResIndex,r)) = 1;
    resDataDep(hash_metric('tputAvg'),hash_data(metric,metric.ResIndex,r)) = 1;
    resDataDep(hash_metric('respTAvg'),hash_data(metric,metric.ResIndex,r)) = 1;
end

sysDataDep = zeros(size(metric.SysData));

end