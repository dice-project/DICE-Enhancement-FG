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
        if strfind(metric.Method,'est')==1
            if length(metric.Result)>1
                replace = sprintf('expr=exp(mean=%d)',metric.Result(metric.classPos));
            else
                replace = sprintf('expr=exp(mean=%d)',metric.Result);
            end
        elseif strfind(metric.Method,'fit')==1
            switch metric.Method
                case 'fit-norm'
                    switch metric.Confidence
                        case 'upper'
                            metric.Result{1} = max(metric.Result{3});
                            metric.Result{2} = max(metric.Result{4});
                        case 'lower'
                            metric.Result{1} = min(metric.Result{3});
                            metric.Result{2} = min(metric.Result{4});
                        case 'none' % do nothing
                    end
                    replace = sprintf('expr=norm(mean=%d, standDev=%d)',metric.Result{1},metric.Result{2});
                case 'fit-exp'
                    replace = sprintf('expr=exp(mean=%d)',metric.Result);
                case 'fit-gamma'
                    shape = metric.Result(1);
                    scale = metric.Result(2);
                    [m] = gamstat(shape,scale);
                    replace = sprintf('expr=gamma(k=%d,mean=%d)',shape,m);
                case 'fit-erl'
                    shape = metric.Result(1);
                    scale = metric.Result(2);
                    [m] = gamstat(shape,scale);
                    replace = sprintf('expr=erl(k=%d,mean=%d)',round(shape),m);
                case 'fit-ph2'
                    MAP=metric.Result;
                    [alpha,T]=map2ph(MAP);
                    replace = sprintf('expr=ph2(lambda0=%d,lambda01=%d,lambda1=%d,alpha0=%d)',-T(1,1),T(1,2),-T(2,2),alpha(1));
                case 'fit-map2'
                    MAP=metric.Result;
                    replace = sprintf('expr=map2(D0_11=%d,D0_12=%d,D0_21=%d,D0_22=%d,D1_11=%d,D1_12=%d,D1_21=%d,D1_22=%d)',MAP{1}(1,1),MAP{1}(1,2),MAP{1}(2,1),MAP{1}(2,2),MAP{2}(1,1),MAP{2}(1,2),MAP{2}(2,1),MAP{2}(2,2));
            end
        end
        f = strrep(f,expression,replace);
        dicefg_disp(1,sprintf('Written UML hostDemand: %s',replace));
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
