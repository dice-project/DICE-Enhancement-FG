function metric=config_parse_dataset(Node,dicefg_disp)
while ~isempty(Node)
    if strcmpi(Node.getNodeName, 'period')
        metric.('startTime') = char(Node.getAttribute('start'));
        metric.('endTime') = char(Node.getAttribute('end'));
    elseif strcmpi(Node.getNodeName, 'parameter')
        metric.(char(Node.getAttribute('type'))) = char(Node.getAttribute('value'));
    end
    Node = Node.getNextSibling;
end
end