function metric=dicefg_handler_est(metric,dicefg_disp)
t_run = tic;
supportedMethods = {'est-ci','est-ubr','est-qbmr','est-qmle','est-sys-jobs','est-sys-extdelay'};
try
    metric.method = validatestring(metric.method,supportedMethods);
    switch metric.method
        case 'est-ci'
            dicefg_disp(1,'Running complete information method (est-ci).');
            flags = dicefg_parseflags(metric);
            [resDataDep,sysDataDep] = est_ci_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied',metric.method));
            end
            arvT={metric.resdata{hash_metric('arvT'),hash_data(metric, metric.resPos, 1:length(metric.resclasses))}};
            respT={metric.resdata{hash_metric('respT'),hash_data(metric, metric.resPos, 1:length(metric.resclasses))}};
            metric.result = est_ci(arvT,respT,flags.numServers,flags.warmUp,dicefg_disp);
            metric.confint = [metric.result,metric.result]; % confidence intervals not available
        case 'est-ubr'
            dicefg_disp(1,'Running utilization-based regression (est-ubr).');
            flags = dicefg_parseflags(metric);
            [resDataDep,sysDataDep] = est_ubr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied',metric.method));
            end
            cpuUtil = metric.resdata{hash_metric('util'),hash_data(metric, metric.resPos, 0)};
            cpuUtil = cpuUtil(:);
            cX = {metric.resdata{hash_metric('tputAvg'),hash_data(metric, metric.resPos, 1:length(metric.resclasses))}};
            avgTput = cell2mat(cX);
            metric.result = est_ubr(cpuUtil,avgTput,flags.numServers,dicefg_disp);
            metric.confint = [metric.result,metric.result]; % confidence intervals not available
        case 'est-qmle'
            dicefg_disp(1,'Running queue-based maximum likelihood estimation (est-qmle).');
            [resDataDep,sysDataDep] = est_qmle_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied.',metric.method));
            end
            % estimate number of jobs
            % estimate think time
%            [metric.result,metric.confint] = est_qmle( metric.resdata, qlSample, nbJobs, thinkTime, data_needed );
        case 'est-qbmr'
            dicefg_disp(1,'Running queue-based memory regression (est-qmr)');
            flags = dicefg_parseflags(metric);
            [resDataDep,sysDataDep] = est_qbmr_dependencies(metric);
            if ~dicefg_preproc_check_dep(metric,resDataDep,sysDataDep)
                error(sprintf('Data dependencies for %s are not satisfied.',metric.method));
            end
            metric.result = est_qbmr(metric.resdata,flags.numServers,dicefg_disp);
            metric.confint = [metric.result,metric.result]; % confidence intervals not available
        case 'est-sys-jobs'
            % not supported yet
        case 'est-sys-extdelay'
            % not supported yet
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
dicefg_disp(1,sprintf('Estimation completed in %.6f seconds.',toc(t_run)));
end