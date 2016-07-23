function fg2json(fileprefix,resdata,graphdata,resources,resclasses,graphclasses)
opt=struct('ArrayToStruct',1);
opt.('FloatFormat')='%.16g';

opt.('FileName')=sprintf('%s-resdata.json',fileprefix);
savejson('resdata',resdata,opt);

opt.('FileName')=sprintf('%s-graphdata.json',fileprefix);
savejson('graphdata',graphdata,opt);

opt.('FileName')=sprintf('%s-resources.json',fileprefix);
savejson('resources',resources,opt);

opt.('FileName')=sprintf('%s-resclasses.json',fileprefix);
savejson('resclasses',resclasses,opt);

opt.('FileName')=sprintf('%s-graphclasses.json',fileprefix);
savejson('graphclasses',graphclasses,opt);
end