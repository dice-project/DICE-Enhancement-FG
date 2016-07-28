function metric=dicefg_handler_fit(metric,dicefg_disp)
t_run = tic;
dicefg_disp(2,sprintf('Direct fitting from measurement selected (%s).',metric.Method));
supportedMethods = {'fit-erl','fit-exp','fit-gamma','fit-norm','fit-ph2','fit-map2'};
try
    metric.Method = validatestring(metric.Method,supportedMethods);
    switch metric.Method
        case 'fit-norm'
            dicefg_disp(1,sprintf('Fitting method selected: normal distribution (%s)',metric.Method))
            [muhat,sigmahat,muci,sigmaci] = normfit();
            metric.Result = [muhat; sigmahat];
            metric.ConfInt = [muci(1), muci(2); sigmaci(1), sigmaci(2)];
        case 'fit-gamma'
            dicefg_disp(1,sprintf('Fitting method selected: gamma distribution (%s)',metric.Method))
            metric.Result = gamfit(get_data(metric,metric.ResIndex,metric.ClassIndex));
        case 'fit-exp'
            dicefg_disp(1,sprintf('Fitting method selected: exponential distribution (%s)',metric.Method))
            metric.Result = expfit(get_data(metric,metric.ResIndex,metric.ClassIndex));
        case 'fit-erl'
            dicefg_disp(1,sprintf('Fitting method selected: Erlang distribution (%s)',metric.Method))
            % we fit an erlang by fitting a gamma and rounding
            % up the shape parameter later on
            metric.Result = gamfit(get_data(metric,metric.ResIndex,metric.ClassIndex));
        case 'fit-ph2'
            dicefg_disp(1,sprintf('Fitting method selected: PH(2) distribution (%s)',metric.Method))
            trace = kpcfit_init(get_data(metric,metric.ResIndex,metric.ClassIndex));
            metric.Result = kpcfit_auto(trace,'OnlyAC',1,'NumStates',2,'MaxRunsAC',1);
            if map_isfeasible(metric.Result)
                g2 = 0; % acf decay rate - 0 since PH is a renewal process
                PH2 = mmpp2_fit3(map_moment(metric.Result,1),map_moment(metric.Result,2),map_moment(metric.Result,3),g2);
                if map_isfeasible(PH2)
                    metric.Result = PH2;
                end
            else
                dicefg_disp(1,'Infeasible PH(2) fitting. Returning exponential.')
                metric.Result = expfit(get_data(metric,metric.ResIndex,metric.ClassIndex));
            end
        case 'fit-map2'
            dicefg_disp(1,sprintf('Fitting method selected: MAP(2) process (%s)',metric.Method))
            trace = kpcfit_init(get_data(metric,metric.ResIndex,metric.ClassIndex));
            metric.Result = kpcfit_auto(trace,'OnlyAC',1,'NumStates',2,'MaxRunsAC',1);
            if ~map_isfeasible(metric.Result) || length(metric.Result{1})==1
                dicefg_disp(1,'Infeasible MAP(2) fitting. Returning exponential.')
                metric.Result = expfit(get_data(metric,metric.ResIndex,metric.ClassIndex));
            end
    end
catch err
    error(sprintf('Unexpected error (%s): %s', metric.Method, err.message));
    exit
end
dicefg_disp(1,sprintf('Fitting completed in %.6f seconds.',toc(t_run)));
end
