function fg2json(fileprefix,resdata,sysdata,resources,resclasses,sysclasses)
opt=struct('ArrayToStruct',1);
opt.('FloatFormat')='%.16g';

opt.('FileName')=sprintf('%s-resdata.json',fileprefix);
savejson('resdata',resdata,opt);

opt.('FileName')=sprintf('%s-sysdata.json',fileprefix);
savejson('sysdata',sysdata,opt);

opt.('FileName')=sprintf('%s-resources.json',fileprefix);
savejson('resources',resources,opt);

opt.('FileName')=sprintf('%s-resclasses.json',fileprefix);
savejson('resclasses',resclasses,opt);

opt.('FileName')=sprintf('%s-sysclasses.json',fileprefix);
savejson('sysclasses',sysclasses,opt);
end