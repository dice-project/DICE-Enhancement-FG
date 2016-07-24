function [resdata,sysdata,resources,resclasses,sysclasses]=json2fg(folder,prefix)
resdataJSON=loadjson(fullfile(folder,sprintf('%s-resdata.json',prefix)));
sysdataJSON=loadjson(fullfile(folder,sprintf('%s-sysdata.json',prefix)));
resclassesJSON=loadjson(fullfile(folder,sprintf('%s-resclasses.json',prefix)));
sysclassesJSON=loadjson(fullfile(folder,sprintf('%s-sysclasses.json',prefix)));
resourceJSON=loadjson(fullfile(folder,sprintf('%s-resources.json',prefix)));

resdataJSON=resdataJSON.resdata;
for j=1:length(resdataJSON)
    for i=1:length(resdataJSON{j})
        resdata{i,j}=resdataJSON{j}{i};
    end
end
resdata=resdata';

sysdataJSON=sysdataJSON.sysdata;
for j=1:length(sysdataJSON)
    for i=1:length(sysdataJSON{j})
        sysdata{i,j}=sysdataJSON{j}{i};
    end
end
sysdata=sysdata';

resclasses=resclassesJSON.resclasses;
sysclasses=sysclassesJSON.sysclasses;
resources=resourceJSON.resources;
end