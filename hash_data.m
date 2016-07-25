function idx=hash_data(metric,i,r)
if r>length(metric.ResClassList)
    warning('Requested class does not exist')
elseif i>length(metric.ResList)
    warning('Requested resource does not exist')
else
    if r==0 % aggregate
        idx = i*(length(metric.ResClassList)+1);
    else
        idx = (i-1)*(length(metric.ResClassList)+1) + r;
    end
end
end