function metric=dicefg_handler_est(metric,dicefg_disp)
t_run = tic;
supportedMethods = {'est-res-ci','est-res-ubr','est-res-qbmr','est-res-qmle','est-res-extdelay'};
try
    metric.Method = validatestring(metric.Method,supportedMethods);
    flags = dicefg_parseflags(metric);
    switch metric.Method
        case 'est-res-ci'
            dicefg_disp(1,'Running resource-level complete information method (est-res-ci).');
            [resDataDep,sysDataDep] = est_res_ci_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied',metric.Method));
            end
            metric.Result = est_res_ci(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result,metric.Result]; % confidence intervals not available
        case 'est-res-ubr'
            dicefg_disp(1,'Running resource-level utilization-based regression (est-res-ubr).');
            [resDataDep,sysDataDep] = est_res_ubr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied',metric.Method));
            end
            metric.Result = est_res_ubr(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result,metric.Result]; % confidence intervals not available
        case 'est-res-qmle'
            dicefg_disp(1,'Running resource-level queue-based maximum likelihood estimation (est-res-qmle).');
            [resDataDep,sysDataDep] = est_res_qmle_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied.',metric.Method));
            end
            % estimate number of jobs
            % estimate think time
            %            [metric.Result,metric.ConfInt] = est_qmle( metric.ResData, qlSample, nbJobs, thinkTime, data_needed );
        case 'est-res-qbmr'
            dicefg_disp(1,'Running resource-level queue-based memory regression (est-res-qmr)');
            [resDataDep,sysDataDep] = est_res_qbmr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied.',metric.Method));
            end
            metric.Result = est_qbmr(metric.ResData,flags.numServers,dicefg_disp);
            metric.ConfInt = [metric.Result,metric.Result]; % confidence intervals not available
        case 'est-res-extdelay'
            dicefg_disp(1,'Running resource-level external delay estimation (est-res-extdelay)');
            metric.Result = est_res_extdelay(metric,flags,dicefg_disp);                        
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
dicefg_disp(1,sprintf('Estimation completed in %.6f seconds.',toc(t_run)));
end