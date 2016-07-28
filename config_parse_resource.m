function metric = config_parse_resource(metric,Node,dicefg_disp)
metric.('Resource') = char(Node.getAttribute('value'));
resFlags = char(Node.getAttribute('flags'));
if length(metric.Flags) > 0 && length(resFlags) > 0
    metric.('Flags') = sprintf('%s, %s',metric.Flags,resFlags);
else % still needs to create the field even if empty
    metric.('Flags') = char(Node.getAttribute('flags'));
end
dicefg_disp(1,sprintf('Processing resource "%s".',metric.Resource));
metric.('ResIndex') = find(cellfun(@(X)strcmpi(metric.Resource,X),metric.ResList));
end
