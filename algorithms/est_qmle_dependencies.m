function [resDataDep,sysDataDep] = est_qmle_dependencies(metric)
% [resDataDep,sysDataDep] = EST_QMLE_DEPENDENCIES(data, resource, class)
% Returns data dependency matrix for est-qmle

resDataDep = zeros(size(metric.resdata));
for i=1:length(metric.resources)
    for r=1:length(metric.resclasses)
        % require average queue-length for each class at each resource, except aggr
        resDataDep(hash_metric('qlenAvg'),hash_data(metric,i,r)) = 1;
    end
end

sysDataDep = zeros(size(metric.sysdata));

end