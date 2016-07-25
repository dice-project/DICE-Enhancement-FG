function metric=dicefg_handler_est(metric,dicefg_disp)
t_run = tic;
supportedMethods = {'est-ci','est-ubr','est-qbmr','est-qmle','est-sys-jobs','est-sys-extdelay'};
try
    metric.Method = validatestring(metric.Method,supportedMethods);
    switch metric.Method
        case 'est-ci'
            dicefg_disp(1,'Running complete information method (est-ci).');
            flags = dicefg_parseflags(metric);
            [resDataDep,sysDataDep] = est_ci_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied',metric.Method));
            end
            metric.Result = est_ci(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result,metric.Result]; % confidence intervals not available
        case 'est-ubr'
            dicefg_disp(1,'Running utilization-based regression (est-ubr).');
            flags = dicefg_parseflags(metric);
            [resDataDep,sysDataDep] = est_ubr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied',metric.Method));
            end
            metric.Result = est_ubr(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result,metric.Result]; % confidence intervals not available
        case 'est-qmle'
            dicefg_disp(1,'Running queue-based maximum likelihood estimation (est-qmle).');
            [resDataDep,sysDataDep] = est_qmle_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied.',metric.Method));
            end
            % estimate number of jobs
            % estimate think time
%            [metric.Result,metric.ConfInt] = est_qmle( metric.ResData, qlSample, nbJobs, thinkTime, data_needed );
        case 'est-qbmr'
            dicefg_disp(1,'Running queue-based memory regression (est-qmr)');
            flags = dicefg_parseflags(metric);
            [resDataDep,sysDataDep] = est_qbmr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied.',metric.Method));
            end
            metric.Result = est_qbmr(metric.ResData,flags.numServers,dicefg_disp);
            metric.ConfInt = [metric.Result,metric.Result]; % confidence intervals not available
        case 'est-sys-jobs'
            % not supported yet
        case 'est-sys-extdelay'
            % not supported yet
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