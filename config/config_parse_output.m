function metric = config_parse_output(metric,Node,dicefg_disp)
metric.('Handler') = char(Node.getAttribute('handler'));
metric.('InputFile') = char(Node.getAttribute('input'));
metric.('OutputFile') = char(Node.getAttribute('output'));
end
