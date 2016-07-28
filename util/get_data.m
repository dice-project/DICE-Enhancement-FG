function data = get_data(metric, metricName, resources, classes)
if length(classes)>1 || length(resources)>1
    data = {metric.ResData{hash_metric(metricName),hash_data(metric, resources, classes)}};
else
    data = metric.ResData{hash_metric(metricName),hash_data(metric, resources, classes)};
end
end