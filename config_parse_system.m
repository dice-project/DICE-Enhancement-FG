function metric = config_parse_system(metric,Node,dicefg_disp)
metric.('System') = char(Node.getAttribute('value'));
resFlags = char(Node.getAttribute('flags'));
if length(metric.Flags) > 0 && length(resFlags) > 0
    metric.('Flags') = sprintf('%s, %s',metric.Flags,resFlags);
else % still needs to create the field even if empty
    metric.('Flags') = char(Node.getAttribute('flags'));
end
dicefg_disp(1,sprintf('Processing system "%s".',metric.System));
metric.('SysIndex') = find(cellfun(@(X)strcmpi(metric.System,X),metric.ResList));
end
