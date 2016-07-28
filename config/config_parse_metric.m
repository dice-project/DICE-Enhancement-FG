function metric = config_parse_metric(metric,Node,dicefg_disp)
metric.('Metric') = char(Node.getAttribute('name'));
metric.('Class') = char(Node.getAttribute('class'));
metric.('Confidence') = char(Node.getAttribute('confidence'));
metric.('Param') = char(Node.getAttribute('param'));
metric.('ParamType') = char(Node.getAttribute('type'));
metric.('ClassIndex') = find(cellfun(@(X)strcmpi(metric.Class,X),metric.ResClassList));
end
