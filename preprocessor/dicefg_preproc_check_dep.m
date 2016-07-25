function bool=dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
bool = true;
for i = 1:size(resDataDep,1)
    for j = 1:size(resDataDep,2)
        if resDataDep(i,j)==1 && isempty(metric.ResData{i,j})
            bool = false; % resource data is missing
        end
    end
end
for i = 1:size(sysDataDep,1)
    for j = 1:size(sysDataDep,2)
        if sysDataDep(i,j)==1 && isempty(metric.sysdata{i,j})
            bool = false; % resource data is missing
        end
    end
end
end