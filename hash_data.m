function idx=hash_data(metric,i,r)
if r>length(metric.resclasses)
    warning('Requested class does not exist')
elseif i>length(metric.resources)
    warning('Requested resource does not exist')
else
    if r==0 % aggregate
        idx = i*(length(metric.resclasses)+1);
    else
        idx = (i-1)*(length(metric.resclasses)+1) + r;
    end
end
end