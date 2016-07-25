%% main function, requires the configuration file as input
function dicefg(configFile)
% put a java.opts file in  mcr_root/<ver>/bin/<arch> with -Xmx2096m
warning off
version = '2.1.0';

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
        dicefg_disp(1,sprintf('FG module - version %s : Copyright 2012-2016 (c) - Imperial College London.\n',version));
    elseif strcmp(node.getNodeName,'dataset')
        subNode = node.getFirstChild;
        while ~isempty(subNode)
            %% read all the custom parameters
            if strcmpi(subNode.getNodeName, 'parameter')
                metric.(char(subNode.getAttribute('name'))) = char(subNode.getAttribute('value'));
            end
            subNode = subNode.getNextSibling;
        end
        try
            %% load data
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
            dicefg_disp(1,sprintf('Dataset has %d resources and %d classes.',length(metric.ResList),length(metric.ResClassList)));
            %% sanitize data
            [nRows,nColumns] = size(metric.ResData);
            if nColumns ~= (length(metric.ResClassList)+1)*length(metric.ResList)
                error('Input files are inconsistent, not enough classes or resources in dataset');
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
        catch err
            err.message
            error(sprintf('Cannot load resource data file: %s',metric.ResourceDataFile));
            exit
        end
    elseif strcmp(node.getNodeName, 'metric')
        subNode = node.getFirstChild;
        while ~isempty(subNode)
            %% a single.Method can be run, hence it determines the subNode
            if strcmpi(subNode.getNodeName, 'method')
                cur = cur + 1;
                metric.('Method') = char(subNode.getTextContent);
            end
            %% read all the custom parameters
            if strcmpi(subNode.getNodeName, 'parameter')
                metric.(char(subNode.getAttribute('name'))) = char(subNode.getAttribute('value'));
            end
            subNode = subNode.getNextSibling;
        end
        metric.('ClassIndex') = find(cellfun(@(X)strcmpi(metric.AnalyzeClass,X),metric.ResClassList));
        metric.('ResIndex') = find(cellfun(@(X)strcmpi(metric.AnalyzeResource,X),metric.ResList));
        %% run the analysis for the metric
        dicefg_disp(1,sprintf('Processing metric %d ("%s" at "%s")',cur,metric.AnalyzeClass,metric.AnalyzeResource));
        
        %% DICE-FG Analyzer
        if strfind(metric.Method,'est')==1
            %% Estimation.Methods
            dicefg_disp(2,'Switching to estimation.Method handler.')
            metric = dicefg_handler_est(metric, dicefg_disp);
        elseif strfind(metric.Method,'fit')==1
            %% Fitting.Methods
            dicefg_disp(2,'Switching to fitting.Method handler.')
            metric = dicefg_handler_fit(metric, dicefg_disp);
        end
        
        %% DICE-FG Updater
        dicefg_disp(2,'Switching to UML update handler.')
        dicefg_disp(1,sprintf('Saving metric %d ("%s" at "%s")',cur,metric.AnalyzeClass,metric.AnalyzeResource));
        dicefg_handler_umlupdate(metric, dicefg_disp);
        
        dicefg_disp(1,sprintf('Metric %d completed.\n',cur));
    end
    node = node.getNextSibling;
end
end
