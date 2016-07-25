function metric=dicefg_handler_fit(metric,dicefg_disp)
t_run = tic;
dicefg_disp(2,sprintf('Direct fitting from measurement selected (%s).',metric.Method));
supportedMethods = {'fit-erl','fit-exp','fit-gamma','fit-norm','fit-ph2','fit-mmpp2'};
try
    metric.Method = validatestring(metric.Method,supportedMethods);
    switch metric.Method
        case 'fit-norm'
            dicefg_disp(1,sprintf('Fitting.Method selected: normal distribution (%s)',metric.Method))
            [muhat,sigmahat,muci,sigmaci] = normfit(metric.ResData{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            metric.Result = {muhat,sigmahat,muci,sigmaci};
        case 'fit-gamma'
            dicefg_disp(1,sprintf('Fitting.Method selected: gamma distribution (%s)',metric.Method))
            metric.Result = gamfit(metric.ResData{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
        case 'fit-exp'
            dicefg_disp(1,sprintf('Fitting.Method selected: exponential distribution (%s)',metric.Method))
            metric.Result = expfit(metric.ResData{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
        case 'fit-erl'
            dicefg_disp(1,sprintf('Fitting.Method selected: Erlang distribution (%s)',metric.Method))
            % we fit an erlang by fitting a gamma and rounding
            % up the shape parameter later on
            metric.Result = gamfit(metric.ResData{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
        case 'fit-ph2'
            dicefg_disp(1,sprintf('Fitting.Method selected: PH(2) distribution (%s)',metric.Method))
            trace = kpcfit_init(metric.ResData{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            metric.Result = kpcfit_auto(trace,'OnlyAC',1,'NumStates',2,'MaxRunsAC',1);
            if map_isfeasible(metric.Result)
                g2 = 0; % acf decay rate - 0 since PH is a renewal process
                PH2 = mmpp2_fit3(map_moment(metric.Result,1),map_moment(metric.Result,2),map_moment(metric.Result,3),g2);
                if map_isfeasible(PH2)
                    metric.Result = PH2;
                end
            else
                dicefg_disp(1,'Infeasible PH(2) fitting. Returning exponential.')
                metric.Result = expfit(metric.ResData{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            end
        case 'fit-mmpp2'
            dicefg_disp(1,sprintf('Fitting.Method selected: MMPP(2) process (%s)',metric.Method))
            trace = kpcfit_init(metric.ResData{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            metric.Result = kpcfit_auto(trace,'OnlyAC',1,'NumStates',2,'MaxRunsAC',1);
            if map_isfeasible(metric.Result)
                g2 = map_acf(metric.Result,2)/map_acf(metric.Result,1); % acf decay rate
                MMPP2 = mmpp2_fit3(map_moment(metric.Result,1),map_moment(metric.Result,2),map_moment(metric.Result,3),g2);
                if map_isfeasible(MMPP2)
                    metric.Result = MMPP2;
                end
            else
                dicefg_disp(1,'Infeasible MMPP(2) fitting. Returning exponential.')
                metric.Result = expfit(metric.ResData{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            end
    end
catch err
    error(sprintf('Unexpected error (%s): %s', metric.Method, err.message));
    exit
end
dicefg_disp(2,'Applying confidence setting.');
switch metric.Confidence
    case 'upper'
        metric.Result = metric.ConfInt(:,2);
    case 'lower'
        metric.Result = metric.ConfInt(:,1);
    case 'mean' % do nothing
end
dicefg_disp(1,sprintf('Fitting completed in %.6f seconds.',toc(t_run)));
end
