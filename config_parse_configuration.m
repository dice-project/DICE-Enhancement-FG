function [configuration] = config_parse_configuration(Node)
while ~isempty(Node)
    % read all the custom parameters
    if strcmpi(Node.getNodeName, 'parameter')
        configuration.(char(Node.getAttribute('type'))) = str2num(Node.getAttribute('value'));
    end
    Node = Node.getNextSibling;
end
end
