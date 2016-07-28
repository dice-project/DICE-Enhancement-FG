function metric = config_parse_estimation(metric,Node,dicefg_disp)
metric.('Algorithm') = char(Node.getAttribute('type'));
metric.('Flags') = char(Node.getAttribute('flags'));
end
