%% main function, requires the configuration file as input
function dicefg(configFile)
% put a java.opts file in  mcr_root/<ver>/bin/<arch> with -Xmx2096m
warning off
version = 0.2;

% Add subfolders
%addpath(genpath(pwd));

% constants
expectednRows = 11; % expected number of rows in data file

%% Parse configuration file
xDoc = xmlread(configFile);
rootNode = xDoc.getDocumentElement.getChildNodes; % get the <DICE-FG> root
node = rootNode.getFirstChild;
cur = 0; % metric counter
while ~isempty(node)
    if strcmp(node.getNodeName, 'verbose')
        verbose=str2num(node.getTextContent);
        if verbose == 0
            dicefg_disp = @dicefg_disp_silent;
        elseif verbose == 1
            dicefg_disp = @dicefg_disp_normal;
        elseif verbose == 2
            dicefg_disp = @dicefg_disp_debug;
        else
            error('Verbose level must be either 0 (slient), 1 (normal) or 2 (debug)');
            exit
        end
        dicefg_disp(1,sprintf('FG version %.1f : Copyright 2012-2016 (c) - Imperial College London.\n',version));
    elseif strcmp(node.getNodeName, 'metric')
        subNode = node.getFirstChild;
        while ~isempty(subNode)
            %% a single method can be run, hence it determines the subNode
            if strcmpi(subNode.getNodeName, 'method')
                cur = cur + 1;
                metric{cur}.('method') = char(subNode.getTextContent);
            end
            %% read all the custom parameters
            if strcmpi(subNode.getNodeName, 'parameter')
                metric{cur}.(char(subNode.getAttribute('name'))) = char(subNode.getAttribute('value'));
            end
            subNode = subNode.getNextSibling;
        end
        %% run the analysis for the metric
        try
            dicefg_disp(1,sprintf('Processing metric %d ("%s" at "%s")',cur,metric{cur}.ClassName,metric{cur}.ResourceName));
            %% load data
            [filePath,fileName,fileExt] = fileparts(metric{cur}.ResourceDataFile);
            if strcmpi(fileExt,'.mat')
                dicefg_disp(1,'Loading resource data (mat format).');
                loadedCell = load(metric{cur}.ResourceDataFile,'resdata'); metric{cur}.resdata=loadedCell.resdata;
                loadedCell = load(metric{cur}.GraphDataFile,'graphdata'); metric{cur}.graphdata=loadedCell.graphdata;
                loadedCell = load(metric{cur}.ResourceClassList,'classes'); metric{cur}.resclasses=loadedCell.resclasses;
                loadedCell = load(metric{cur}.ResourceList,'resources'); metric{cur}.resources=loadedCell.resources;
            elseif strcmpi(fileExt,'.json')
                dicefg_disp(1,'Loading resource data (JSON format).');
                fileName = strrep(fileName,'-resdata','');
                [metric{cur}.resdata,metric{cur}.graphdata,metric{cur}.resources,metric{cur}.resclasses]=json2fg(filePath,fileName);
            else
                error('Only .mat data files are supported in the current version.')
                exit
            end
            dicefg_disp(1,sprintf('Dataset has %d resources and %d classes.',length(metric{cur}.resources),length(metric{cur}.resclasses)));
            %% sanitize data
            [nRows,nColumns] = size(metric{cur}.resdata);
            if nColumns ~= (length(metric{cur}.resclasses)+1)*length(metric{cur}.resources)
                error('Input files are inconsistent, not enough classes or resources in dataset');
                exit
            end
            if nRows<expectednRows
                dicefg_disp(0,'Data does not include all rows. Adding empty rows.')
                for i=nRows+1:expectednRows
                    for j=1:nColumns
                        metric{cur}.resdata{i,j}=[];
                    end
                end
            end
        catch err
            err.message
            error(sprintf('Cannot load resource data file: %s',metric{cur}.ResourceDataFile));
            exit
        end
        switch metric{cur}.Technology
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
        
        %% DICE-FG Analyzer
        if strfind(metric{cur}.method,'est')==1
            %% Estimation methods
            dicefg_disp(2,'Switching to estimation method handler.')
            metric{cur} = dicefg_handler_est(metric{cur}, dicefg_disp);
        elseif strfind(metric{cur}.method,'fit')==1
            %% Fitting methods
            dicefg_disp(2,'Switching to fitting method handler.')
            metric{cur} = dicefg_handler_fit(metric{cur}, dicefg_disp);
        end
        
        %% DICE-FG Updater
        dicefg_disp(2,'Switching to UML update handler.')
        dicefg_handler_umlupdate(metric{cur}, dicefg_disp);
        
        dicefg_disp(1,sprintf('Metric %d completed.\n',cur));
    end
    node = node.getNextSibling;
end
end
