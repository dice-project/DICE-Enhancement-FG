function metric = config_parse_fitting(metric,Node,dicefg_disp)
metric.('Algorithm') = char(Node.getAttribute('type'));
metric.('Flags') = char(Node.getAttribute('flags'));
end