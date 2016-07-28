function metric = config_parse_output(metric,Node,dicefg_disp)
metric.('Handler') = char(Node.getAttribute('handler'));
metric.('OutputFile') = char(Node.getAttribute('path'));
end
