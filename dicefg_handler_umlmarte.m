function dicefg_handler_umlmarte(metric, dicefg_disp)
dicefg_disp(2,sprintf('Updating context parameter %s in UML model.',metric.Param));
try
    dicefg_disp(2,'Applying confidence setting.');
    switch metric.Confidence
        case 'upper'
            metric.Result = metric.ConfInt(:,2);
        case 'lower'
            metric.Result = metric.ConfInt(:,1);
        case 'mean' % do nothing
    end
    dicefg_disp(2,'Reading input UML model');
    fid  = fopen(metric.OutputFile,'r');
    f=fread(fid,'*char')';
    fclose(fid);
    dicefg_disp(2,'Updating model');
    if strcmpi(metric.ParamType,'hostDemand')==1
        expression = sprintf('expr=%s',metric.Param);
        if strfind(metric.Algorithm,'est')==1
            if length(metric.Result)>1
                replace = sprintf('expr=exp(mean=%.3f)',metric.Result(metric.ClassIndex));
            else
                replace = sprintf('expr=exp(mean=%.3f)',metric.Result);
            end
        elseif strfind(metric.Algorithm,'fit')==1
            switch metric.Algorithm
                case 'fit-mean'
                    replace = sprintf('expr=%.2f',metric.Result);
                case 'fit-norm'
                    replace = sprintf('expr=norm(mean=%.3f, standDev=%.3f)',metric.Result(1),metric.Result(2));
                case 'fit-exp'
                    replace = sprintf('expr=exp(mean=%.3f)',metric.Result);
                case 'fit-gamma'
                    shape = metric.Result(1);
                    scale = metric.Result(2);
                    [m] = gamstat(shape,scale);
                    replace = sprintf('expr=gamma(k=%.3f,mean=%.3f)',shape,m);
                case 'fit-erl'
                    shape = metric.Result(1);
                    scale = metric.Result(2);
                    [m] = gamstat(shape,scale);
                    replace = sprintf('expr=erl(k=%.3f,mean=%.3f)',round(shape),m);
                case 'fit-ph2'
                    MAP=metric.Result;
                    [alpha,T]=map2ph(MAP);
                    replace = sprintf('expr=ph2(T_11=%.3f,T_12=%.3f,T_21=%.3f,T_22=%.3f,alpha1=%.3f,alpha2=%.3f)',T(1,1),T(1,2),T(2,1),T(2,2),alpha(1),alpha(2));
                case 'fit-map2'
                    MAP=metric.Result;
                    replace = sprintf('expr=map2(D0_11=%.3f,D0_12=%.3f,D0_21=%.3f,D0_22=%.3f,D1_11=%.3f,D1_12=%.3f,D1_21=%.3f,D1_22=%.3f)',MAP{1}(1,1),MAP{1}(1,2),MAP{1}(2,1),MAP{1}(2,2),MAP{2}(1,1),MAP{2}(1,2),MAP{2}(2,1),MAP{2}(2,2));
            end
        end
        f = strrep(f,expression,replace);
        dicefg_disp(1,sprintf('Writing UML MARTE hostDemand (contextParam: %s): %s',metric.Param,replace));
        dicefg_disp(1,sprintf('Expression: %s\nReplaced: %s',expression,replace));
    end
    dicefg_disp(1,sprintf('Writing output UML MARTE model: %s',metric.OutputFile));
    fid  = fopen(metric.OutputFile,'w');
    fprintf(fid,'%s',f);
    fclose(fid);
catch err
    error('Unexpected error: %s',err.message);
    exit
end
end
