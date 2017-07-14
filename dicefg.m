function dicefg(configFile)
% DICEFG(configFile)
% Run DICE-FG tool using the specified configuration XML file.
version = '2.3.0';
xDoc = xmlread(configFile);
rootNode = xDoc.getDocumentElement.getChildNodes; % get the <DICE-FG> root

Node = rootNode.getFirstChild;
while ~isempty(Node)
    if strcmp(Node.getNodeName, 'configuration')
        [configuration] = config_parse_configuration(Node.getFirstChild);
        dicefg_disp = setup_display(configuration);
        dicefg_disp(1,sprintf('FG module - version %s - copyright 2012-2016 (c) - Imperial College London.',version));
    elseif strcmp(Node.getNodeName,'dataset')
        metric = config_parse_dataset(Node.getFirstChild,dicefg_disp);
        metric = data_load(metric, dicefg_disp);
        metric = data_validation(metric, dicefg_disp);
    elseif strcmp(Node.getNodeName,'estimation') || strcmp(Node.getNodeName,'fitting')
        metric = setDefaults(metric);
        if strcmp(Node.getNodeName,'estimation')
            metric = config_parse_estimation(metric,Node,dicefg_disp);
        elseif strcmp(Node.getNodeName,'fitting')
            metric = config_parse_fitting(metric,Node,dicefg_disp);
        end
        subNode0 = Node.getFirstChild;
        while ~isempty(subNode0)
            if strcmpi(subNode0.getNodeName, 'resource')
                metric = config_parse_resource(metric,subNode0,dicefg_disp);
            elseif strcmpi(subNode0.getNodeName, 'system')
                metric = config_parse_system(metric,Node,dicefg_disp);
            end
            if strcmp(Node.getNodeName,'estimation')
                if strcmpi(subNode0.getNodeName, 'resource')
                    metric = dicefg_handler_res_est(metric, dicefg_disp);
                elseif strcmpi(subNode0.getNodeName, 'system')
                    metric = dicefg_handler_sys_est(metric, dicefg_disp);
                end
            end
            subNode1 = subNode0.getFirstChild;
            while ~isempty(subNode1)
                if strcmpi(subNode1.getNodeName, 'output')
                    metric = config_parse_output(metric,subNode1,dicefg_disp);
                    subNode2 = subNode1.getFirstChild;
                    while ~isempty(subNode2)
                        if strcmpi(subNode2.getNodeName, 'metric')
                            metric = config_parse_metric(metric,subNode2,dicefg_disp);
                            if strcmp(Node.getNodeName,'fitting')
                                metric = dicefg_handler_fit(metric, dicefg_disp);
                            end
                            metric = dicefg_actuator(metric, dicefg_disp);
                        end
                        subNode2 = subNode2.getNextSibling;
                    end
                end
                subNode1 = subNode1.getNextSibling;
            end
            subNode0 = subNode0.getNextSibling;
        end
    end
    Node = Node.getNextSibling;
end
end

function metric = setDefaults(metric)
metric.('Confidence')='mean';
metric.('Flags')='';
metric.('Class')='';
metric.('Resource')='';
metric.('Metric')='';
metric.('Param')='';
metric.('ParamType')='';
metric.('OutputFile')='';
end

function dicefg_disp = setup_display(configuration)
if configuration.Verbose == 0
    dicefg_disp = @dicefg_disp_silent;
elseif configuration.Verbose == 2
    dicefg_disp = @dicefg_disp_debug;
else % use normal in case of input errors
    dicefg_disp = @dicefg_disp_normal;
end
end