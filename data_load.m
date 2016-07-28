function metric = data_load(metric, dicefg_disp)
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
    case 'agnostic'
        dicefg_disp(2,'Running in technology-agnostic mode.')
end
dicefg_disp(2,sprintf('Dataset has %d resources and %d classes.',metric.NumResources,metric.NumClasses));
end
