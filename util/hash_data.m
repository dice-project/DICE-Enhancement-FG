function idx=hash_data(metric,i,r)
if r>metric.NumClasses
    warning('Requested class does not exist')
elseif i>metric.NumResources
    warning('Requested resource does not exist')
else
    if r==0 % aggregate
        idx = i*(metric.NumClasses+1);
    else
        idx = (i-1)*(metric.NumClasses+1) + r;
    end
end
end