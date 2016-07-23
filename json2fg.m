function [resdata,graphdata,resources,resclasses,graphclasses]=json2fg(folder,prefix)
resdataJSON=loadjson(fullfile(folder,sprintf('%s-resdata.json',prefix)));
graphdataJSON=loadjson(fullfile(folder,sprintf('%s-graphdata.json',prefix)));
resclassesJSON=loadjson(fullfile(folder,sprintf('%s-resclasses.json',prefix)));
graphclassesJSON=loadjson(fullfile(folder,sprintf('%s-graphclasses.json',prefix)));
resourceJSON=loadjson(fullfile(folder,sprintf('%s-resources.json',prefix)));

resdataJSON=resdataJSON.resdata;
for j=1:length(resdataJSON)
    for i=1:length(resdataJSON{j})
        resdata{i,j}=resdataJSON{j}{i};
    end
end
resdata=resdata';

graphdataJSON=graphdataJSON.graphdata;
for j=1:length(graphdataJSON)
    for i=1:length(graphdataJSON{j})
        graphdata{i,j}=graphdataJSON{j}{i};
    end
end
graphdata=graphdata';

resclasses=resclassesJSON.resclasses;
graphclasses=graphclassesJSON.graphclasses;
resources=resourceJSON.resources;
end