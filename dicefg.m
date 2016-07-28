function dicefg(configFile)
% DICEFG(configFile)
% Run DICE-FG tool using the specified configuration XML file.

version = '2.3.0';

expectednRows = 11; % expected number of rows in data file

xDoc = xmlread(configFile);
rootNode = xDoc.getDocumentElement.getChildNodes; % get the <DICE-FG> root
node = rootNode.getFirstChild;
while ~isempty(node)
    if strcmp(node.getNodeName, 'configuration')
        subNode2 = node.getFirstChild;
        while ~isempty(subNode2)
            % read all the custom parameters
            if strcmpi(subNode2.getNodeName, 'parameter')
                configuration.(char(subNode2.getAttribute('type'))) = str2num(subNode2.getAttribute('value'));
            end
            subNode2 = subNode2.getNextSibling;
        end
        if configuration.Verbose == 0
            dicefg_disp = @dicefg_disp_silent;
        elseif configuration.Verbose == 1
            dicefg_disp = @dicefg_disp_normal;
        elseif configuration.Verbose == 2
            dicefg_disp = @dicefg_disp_debug;
        else
            error('Verbose level must be either 0 (silent), 1 (normal) or 2 (debug)');
            exit
        end
        dicefg_disp(1,sprintf('FG module - version %s: Copyright 2012-2016 (c) - Imperial College London.',version));
    elseif strcmp(node.getNodeName,'dataset')
        subNode2 = node.getFirstChild;
        while ~isempty(subNode2)
            % read all the custom parameters
            if strcmpi(subNode2.getNodeName, 'parameter')
                metric.(char(subNode2.getAttribute('type'))) = char(subNode2.getAttribute('value'));
            end
            subNode2 = subNode2.getNextSibling;
        end
        try
            %% Data loading phase
            [filePath,fileName,fileExt] = fileparts(metric.ResourceDataFile);
            if strcmpi(fileExt,'.mat')
                dicefg_disp(1,'Loading resource data (mat format).');
                loadedCell = load(metric.ResourceDataFile,'resdata'); metric.ResData=loadedCell.resdata;
                loadedCell = load(metric.SystemDataFile,'sysdata'); metric.SysData=loadedCell.sysdata;
                loadedCell = load(metric.ResourceClassList,'classes'); metric.ResClassList=loadedCell.resclasses;
                loadedCell = load(metric.ResourceList,'resources'); metric.ResList=loadedCell.resources;
            elseif strcmpi(fileExt,'.json')
                dicefg_disp(1,'Loading resource data (JSON format).');
                fileName = strrep(fileName,'-resdata','');
                [metric.ResData,metric.SysData,metric.ResList,metric.ResClassList]=json2fg(filePath,fileName);
            else
                error('Only .mat data files are supported in the current version.')
                exit
            end
            metric.('NumResources') = length(metric.ResList);
            metric.('NumClasses') = length(metric.ResClassList);
            switch metric.Technology
                case 'hadoop'
                    dicefg_disp(2,'Running in technology-specific mode: Apache Hadoop dataset.')
                    dicefg_disp(1,'Loading Apache Hadoop information.')
                    % todo
                case 'spark'
                    dicefg_disp(2,'Running in technology-specific mode: Apache Spark dataset.')
                    dicefg_disp(1,'Loading Apache Spark information.')
                    % todo
                case 'storm'
                    dicefg_disp(2,'Running in technology-specific mode: Apache Storm dataset.')
                    dicefg_disp(1,'Loading Apache Storm information.')
                    % todo
                case 'agnostic'
                    dicefg_disp(2,'Running in technology-agnostic mode.')
            end
            dicefg_disp(2,sprintf('Dataset has %d resources and %d classes.',metric.NumResources,metric.NumClasses));
            %% Data validation phase
            [nRows,nColumns] = size(metric.ResData);
            if nColumns ~= (metric.NumClasses+1)*metric.NumResources
                error('Input files are inconsistent, not enough classes or resources in dataset.');
                exit
            end
            if nRows<expectednRows
                dicefg_disp(0,'Data does not include all rows. Adding empty rows.')
                for i=nRows+1:expectednRows
                    for j=1:nColumns
                        metric.ResData{i,j}=[];
                    end
                end
            end
        catch err
            err.message
            error('Cannot load resource data file: %s.',metric.ResourceDataFile);
            exit
        end
        %% Resource-level analysis
    elseif strcmp(node.getNodeName,'analysis')
        metric.('Algorithm') = char(node.getAttribute('algorithm'));
        metric.('Flags') = char(node.getAttribute('flags'));
        subNode0 = node.getFirstChild;
        while ~isempty(subNode0)
            if strcmpi(subNode0.getNodeName, 'resource')
                metric = setMetricDefaults(metric);
                metric.('Resource') = char(subNode0.getAttribute('value'));
                dicefg_disp(1,sprintf('Processing resource "%s".',metric.Resource));
                metric.('ResIndex') = find(cellfun(@(X)strcmpi(metric.Resource,X),metric.ResList));
                
                if strfind(metric.Algorithm,'est-')==1
                    dicefg_disp(2,'Switching to resource-level estimation method handler.')
                    metric = dicefg_handler_res_est(metric, dicefg_disp);
                end
                
                subNode1 = subNode0.getFirstChild;
                while ~isempty(subNode1)
                    if strcmpi(subNode1.getNodeName, 'output')
                        subNode2 = subNode1.getFirstChild;
                        while ~isempty(subNode2)
                            % read all the custom parameters
                            if strcmpi(subNode2.getNodeName, 'parameter')
                                metric.(char(subNode2.getAttribute('type'))) = char(subNode2.getAttribute('value'));
                            end
                            subNode2 = subNode2.getNextSibling;
                        end
                        metric.('ClassIndex') = find(cellfun(@(X)strcmpi(metric.Class,X),metric.ResClassList));
                        
                        if strfind(metric.Algorithm,'fit-')==1
                            dicefg_disp(2,'Switching to fitting method handler.')
                            metric = dicefg_handler_fit(metric, dicefg_disp);
                        end
                        
                        dicefg_disp(2,'Applying confidence setting.');
                        switch metric.Confidence
                            case 'upper'
                                metric.Result = metric.ConfInt(:,2);
                            case 'lower'
                                metric.Result = metric.ConfInt(:,1);
                            case 'mean' % do nothing
                        end
                        
                        %% Model updating phase
                        dicefg_disp(2,'Switching to UML update handler.')
                        dicefg_disp(2,sprintf('Saving metric "%s" at "%s"',metric.Class,metric.Resource));
                        dicefg_handler_umlupdate(metric, dicefg_disp);
                    end
                    subNode1 = subNode1.getNextSibling;
                end
            end
            subNode0 = subNode0.getNextSibling;
        end
    end
    node = node.getNextSibling;
end
end

function metric=setMetricDefaults(metric)
metric.('Confidence')='mean';
metric.('Flags')='';
metric.('Class')='';
metric.('Resource')='';
metric.('Metric')='';
metric.('UMLParam')='';
metric.('UMLParamType')='';
metric.('UMLInput')='';
metric.('UMLOutput')='';
end