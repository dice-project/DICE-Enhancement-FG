function metric=dicefg_handler_res_est(metric,dicefg_disp)
t_run = tic;
supportedAlgorithms = {'est-ci','est-ubr','est-qbmr',...
                    'est-qmle','est-extdelay',...
                    'est-maxpopulation','est-maxavgpopulation'};
try
    metric.Algorithm = validatestring(metric.Algorithm,supportedAlgorithms);
    flags = dicefg_parseflags(metric);
    switch metric.Algorithm
        case 'est-ci'
            dicefg_disp(1,'Running resource-level complete information method (est-ci).');
            [resDataDep,sysDataDep] = est_res_ci_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error('Data dependencies for %s are not satisfied',metric.Algorithm);
            end
            metric.Result = est_res_ci(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result(:),metric.Result(:)]; % confidence intervals not available
        case 'est-ubr'
            dicefg_disp(1,'Running resource-level utilization-based regression (est-ubr).');
            [resDataDep,sysDataDep] = est_res_ubr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error('Data dependencies for %s are not satisfied',metric.Algorithm);
            end
            metric.Result = est_res_ubr(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result(:),metric.Result(:)]; % confidence intervals not available
        case 'est-qmle'
            dicefg_disp(1,'Running resource-level queue-based maximum likelihood estimation (est-qmle).');
            [resDataDep,sysDataDep] = est_res_qmle_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error('Data dependencies for %s are not satisfied.',metric.Algorithm);
            end
            [metric.Result,sigma] = est_res_qmle( metric,flags,dicefg_disp );
            metric.ConfInt(1:2,1) = [metric.Result(:)-sigma(:)]';
            metric.ConfInt(1:2,2) = [metric.Result(:)+sigma(:)]';
        case 'est-qbmr'
            dicefg_disp(1,'Running resource-level queue-based memory regression (est-qmr)');
            [resDataDep,sysDataDep] = est_res_qbmr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error('Data dependencies for %s are not satisfied.',metric.Algorithm);
            end
            metric.Result = est_qbmr(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result(:),metric.Result(:)]; % confidence intervals not available
        case 'est-extdelay'
            dicefg_disp(1,'Running resource-level external delay estimation (est-extdelay)');
            metric.Result = est_res_extdelay(metric,flags,dicefg_disp);                        
            metric.ConfInt = [metric.Result(:),metric.Result(:)]; % confidence intervals not available
        case 'est-maxpopulation'
            dicefg_disp(1,'Running resource-level max population estimation (est-max-population)');
            metric.Result = est_res_max_population(metric,flags,dicefg_disp);
            metric.ConfInt = [metric.Result(:),metric.Result(:)]; % confidence intervals not available
    end
catch err
    error('Unexpected error (%s): %s', metric.Algorithm, err.message);
    exit
end
dicefg_disp(2,sprintf('Estimation completed in %.6f seconds.',toc(t_run)));
end