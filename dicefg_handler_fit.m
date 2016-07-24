function metric=dicefg_handler_fit(metric,dicefg_disp)
t_run = tic;
dicefg_disp(2,sprintf('Direct fitting from measurement selected (%s).',metric.method));
supportedMethods = {'fit-erl','fit-exp','fit-gamma','fit-norm','fit-ph2','fit-mmpp2'};
try
    metric.method = validatestring(metric.method,supportedMethods);
    switch metric.method
        case 'fit-norm'
            dicefg_disp(1,sprintf('Fitting method selected: normal distribution (%s)',metric.method))
            [muhat,sigmahat,muci,sigmaci] = normfit(metric.resdata{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            metric.result = {muhat,sigmahat,muci,sigmaci};
        case 'fit-gamma'
            dicefg_disp(1,sprintf('Fitting method selected: gamma distribution (%s)',metric.method))
            metric.result = gamfit(metric.resdata{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
        case 'fit-exp'
            dicefg_disp(1,sprintf('Fitting method selected: exponential distribution (%s)',metric.method))
            metric.result = expfit(metric.resdata{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
        case 'fit-erl'
            dicefg_disp(1,sprintf('Fitting method selected: Erlang distribution (%s)',metric.method))
            % we fit an erlang by fitting a gamma and rounding
            % up the shape parameter later on
            metric.result = gamfit(metric.resdata{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
        case 'fit-ph2'
            dicefg_disp(1,sprintf('Fitting method selected: PH(2) distribution (%s)',metric.method))
            trace = kpcfit_init(metric.resdata{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            metric.result = kpcfit_auto(trace,'OnlyAC',1,'NumStates',2,'MaxRunsAC',1);
            if map_isfeasible(metric.result)
                g2 = 0; % acf decay rate - 0 since PH is a renewal process
                PH2 = mmpp2_fit3(map_moment(metric.result,1),map_moment(metric.result,2),map_moment(metric.result,3),g2);
                if map_isfeasible(PH2)
                    metric.result = PH2;
                end
            else
                dicefg_disp(1,'Infeasible PH(2) fitting. Returning exponential.')
                metric.result = expfit(metric.resdata{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            end
        case 'fit-mmpp2'
            dicefg_disp(1,sprintf('Fitting method selected: MMPP(2) process (%s)',metric.method))
            trace = kpcfit_init(metric.resdata{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            metric.result = kpcfit_auto(trace,'OnlyAC',1,'NumStates',2,'MaxRunsAC',1);
            if map_isfeasible(metric.result)
                g2 = map_acf(metric.result,2)/map_acf(metric.result,1); % acf decay rate
                MMPP2 = mmpp2_fit3(map_moment(metric.result,1),map_moment(metric.result,2),map_moment(metric.result,3),g2);
                if map_isfeasible(MMPP2)
                    metric.result = MMPP2;
                end
            else
                dicefg_disp(1,'Infeasible MMPP(2) fitting. Returning exponential.')
                metric.result = expfit(metric.resdata{hash_metric(metric.AnalyzeMetric),hash_data(metric,metric.resPos,metric.classPos)});
            end
    end
catch err
    error(sprintf('Unexpected error (%s): %s', metric.method, err.message));
    exit
end
dicefg_disp(2,'Applying confidence setting.');
switch metric.Confidence
    case 'upper'
        metric.result = metric.confint(:,2);
    case 'lower'
        metric.result = metric.confint(:,1);
    case 'mean' % do nothing
end
dicefg_disp(1,sprintf('Fitting completed in %.6f seconds.',toc(t_run)));
end
