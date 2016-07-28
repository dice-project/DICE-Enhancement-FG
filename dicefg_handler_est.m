function metric=dicefg_handler_est(metric,dicefg_disp)
t_run = tic;
supportedMethods = {'est-res-ci','est-res-ubr','est-res-qbmr',...
                    'est-res-qmle','est-res-extdelay',...
                    'est-res-maxpopulation','est-res-maxavgpopulation'};
try
    metric.Method = validatestring(metric.Method,supportedMethods);
    flags = dicefg_parseflags(metric);
    switch metric.Method
        case 'est-res-ci'
            dicefg_disp(1,'Running resource-level complete information method (est-res-ci).');
            [resDataDep,sysDataDep] = est_res_ci_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error('Data dependencies for %s are not satisfied',metric.Method);
            end
            metric.Result = est_res_ci(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result,metric.Result]; % confidence intervals not available
        case 'est-res-ubr'
            dicefg_disp(1,'Running resource-level utilization-based regression (est-res-ubr).');
            [resDataDep,sysDataDep] = est_res_ubr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error('Data dependencies for %s are not satisfied',metric.Method);
            end
            metric.Result = est_res_ubr(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result,metric.Result]; % confidence intervals not available
        case 'est-res-qmle'
            dicefg_disp(1,'Running resource-level queue-based maximum likelihood estimation (est-res-qmle).');
            [resDataDep,sysDataDep] = est_res_qmle_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error('Data dependencies for %s are not satisfied.',metric.Method);
            end
            [metric.Result,sigma] = est_res_qmle( metric,flags,dicefg_disp );
            metric.ConfInt(1:2,1) = [metric.Result-sigma]';
            metric.ConfInt(1:2,2) = [metric.Result+sigma]';
        case 'est-res-qbmr'
            dicefg_disp(1,'Running resource-level queue-based memory regression (est-res-qmr)');
            [resDataDep,sysDataDep] = est_res_qbmr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error('Data dependencies for %s are not satisfied.',metric.Method);
            end
            metric.Result = est_qbmr(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result,metric.Result]; % confidence intervals not available
        case 'est-res-extdelay'
            dicefg_disp(1,'Running resource-level external delay estimation (est-res-extdelay)');
            metric.Result = est_res_extdelay(metric,flags,dicefg_disp);                        
        case 'est-res-maxpopulation'
            dicefg_disp(1,'Running resource-level max population estimation (est-max-population)');
            metric.Result = est_res_max_population(metric,flags,dicefg_disp);
    end
catch err
    error('Unexpected error (%s): %s', metric.Method, err.message);
    exit
end
dicefg_disp(2,sprintf('Estimation completed in %.6f seconds.',toc(t_run)));
end