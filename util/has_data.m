function bool = has_data(metric, metricName, resources, classes)
bool = 1;
for i=1:resources
    for r=1:classes
        bool = min(bool, isemtpy(get_data(metric,metricName,i,r))); 
    end
end
end