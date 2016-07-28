function [resDataDep,sysDataDep] = est_res_max_population_dependencies(metric)
% [resDataDep,sysDataDep] = EST_RES_MAX_POPULATION_DEPENDENCIES(metric)
% Returns data dependency matrix for est-res-maxpopulation

resDataDep = zeros(size(metric.ResData));
for r=1:length(metric.ResClassList)
    % require average queue-length for each class at each resource, except aggr
    resDataDep(hash_metric('arvT'),hash_data(metric,metric.ResIndex,r)) = 1;
    resDataDep(hash_metric('respT'),hash_data(metric,metric.ResIndex,r)) = 1;
end

sysDataDep = zeros(size(metric.SysData));

end