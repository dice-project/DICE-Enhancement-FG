function [resDataDep,sysDataDep] = est_res_maxavg_population_dependencies(metric)
% [resDataDep,sysDataDep] = EST_EXTDELAY_DEPENDENCIES(data, resource, class)
% Returns data dependency matrix for est-ci

resDataDep = zeros(size(metric.ResData));
for r=1:metric.NumClasses
    resDataDep(hash_metric('qlenAvg'),hash_data(metric,metric.ResIndex,r)) = 1;
end

sysDataDep = zeros(size(metric.SysData));

end