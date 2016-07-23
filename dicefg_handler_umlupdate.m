function dicefg_handler_umlupdate(metric, dicefg_disp)
dicefg_disp(1,sprintf('Updating context parameter %s in UML model.',metric.UMLParam));
try
    dicefg_disp(2,'Reading input UML model');
    fid  = fopen(metric.UMLInput,'r');
    f=fread(fid,'*char')';
    fclose(fid);
    dicefg_disp(2,'Updating model');
    if strcmpi(metric.UMLParamType,'hostDemand')==1
        expression = sprintf('expr=%s',metric.UMLParam);
        if strfind(metric.method,'est')==1
            if length(metric.result)>1
                classPos = find(cellfun(@(X)strcmpi(metric.ClassName,X),metric.resclasses));
                replace = sprintf('expr=exp(mean=%16f)',metric.result(classPos));
            else
                replace = sprintf('expr=exp(mean=%16f)',metric.result);
            end
        elseif strfind(metric.method,'fit')==1
            switch metric.method
                case 'fit-norm'
                    switch metric.Confidence
                        case 'upper'
                            metric.result{1} = max(metric.result{3});
                            metric.result{2} = max(metric.result{4});
                        case 'lower'
                            metric.result{1} = min(metric.result{3});
                            metric.result{2} = min(metric.result{4});
                        case 'none' % do nothing
                    end
                    replace = sprintf('expr=norm(mean=%16f, standDev=%16f)',metric.result{1},metric.result{2});
                case 'fit-exp'
                    replace = sprintf('expr=exp(mean=%16f)',metric.result);
                case 'fit-gamma'
                    shape = metric.result(1);
                    scale = metric.result(2);
                    [m] = gamstat(shape,scale);
                    replace = sprintf('expr=gamma(k=%16f,mean=%16f)',shape,m);
                case 'fit-erl'
                    shape = metric.result(1);
                    scale = metric.result(2);
                    [m] = gamstat(shape,scale);
                    replace = sprintf('expr=erl(k=%16f,mean=%16f)',round(shape),m);
                case 'fit-ph2'
                    MAP=metric.result;
                    [alpha,T]=map2ph(MAP);
                    replace = sprintf('expr=ph2(lambda0=%16f,lambda01=%16f,lambda1=%16f,alpha0=%16f)',-T(1,1),T(1,2),-T(2,2),alpha(1));
                case 'fit-mmpp2'
                    MAP=metric.result;
                    replace = sprintf('expr=mmpp2(lambda0=%16f,lambda1=%16f,sigma0=%16f,sigma1=%16f)',MAP{2}(1,1),MAP{2}(2,2),MAP{1}(1,2),MAP{1}(2,1));
            end
        end
        f = strrep(f,expression,replace);
        dicefg_disp(2,sprintf('Expression: %s\nReplaced: %s',expression,replace));
    end
    dicefg_disp(2,'Writing output UML model');
    fid  = fopen(metric.UMLOutput,'w');
    fprintf(fid,'%s',f);
    fclose(fid);
catch err
    error(sprintf('Unexpected error: %s',err.message));
    exit
end
end
