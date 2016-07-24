function bool=dicefg_preproc_check_dep(metric,resDataDep,graphDataDep)
bool = true;
for i = 1:size(resDataDep,1)
    for j = 1:size(resDataDep,2)
        if resDataDep(i,j)==1 && isempty(metric.resdata{i,j})
            bool = false; % resource data is missing
        end
    end
end
for i = 1:size(graphDataDep,1)
    for j = 1:size(graphDataDep,2)
        if graphDataDep(i,j)==1 && isempty(metric.graphdata{i,j})
            bool = false; % resource data is missing
        end
    end
end
end