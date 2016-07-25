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
                replace = sprintf('expr=exp(mean=%d)',metric.result(metric.classPos));
            else
                replace = sprintf('expr=exp(mean=%d)',metric.result);
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
                    replace = sprintf('expr=norm(mean=%d, standDev=%d)',metric.result{1},metric.result{2});
                case 'fit-exp'
                    replace = sprintf('expr=exp(mean=%d)',metric.result);
                case 'fit-gamma'
                    shape = metric.result(1);
                    scale = metric.result(2);
                    [m] = gamstat(shape,scale);
                    replace = sprintf('expr=gamma(k=%d,mean=%d)',shape,m);
                case 'fit-erl'
                    shape = metric.result(1);
                    scale = metric.result(2);
                    [m] = gamstat(shape,scale);
                    replace = sprintf('expr=erl(k=%d,mean=%d)',round(shape),m);
                case 'fit-ph2'
                    MAP=metric.result;
                    [alpha,T]=map2ph(MAP);
                    replace = sprintf('expr=ph2(lambda0=%d,lambda01=%d,lambda1=%d,alpha0=%d)',-T(1,1),T(1,2),-T(2,2),alpha(1));
                case 'fit-mmpp2'
                    MAP=metric.result;
                    replace = sprintf('expr=mmpp2(lambda0=%d,lambda1=%d,sigma0=%d,sigma1=%d)',MAP{2}(1,1),MAP{2}(2,2),MAP{1}(1,2),MAP{1}(2,1));
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
