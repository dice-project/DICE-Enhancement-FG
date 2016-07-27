function [demEst,fObjFun] = ubo(data,maxTime)
% UBO Utilization-based optimization statistical data analyzer (SDA) 
% This SDA is based on the method proposed in 
% Liu, Z., Wynter, L., Xia, C. H. and Zhang, F. 
% Parameter inference of queueing models for IT systems using end-to-end measurements 
% Performance Evaluation, Elsevier, 2006. 
%
% [D,F] = UBO(data,maxTime) reads the data and configuration 
% parameters from the input parameters, estimates the resource
% demand for each request class and returns it on D. 
%
% Configuration file fields:
% data:         the input data for the SDA
% maxTime:      maximum running time (s) for optimization procedure
%
% 
% Copyright (c) 2012-2013, Imperial College London 
% All rights reserved.
% This code is released under the 3-Clause BSD License. 

%%
if exist('data','var') == 0
    disp('No data provided specified. Terminating without running SDA.');
    meanST = [];
    obs = [];
    return;
end
% SDA parameters
if exist('maxTime','var') ~= 0
    MAXTIME = maxTime;
    if MAXTIME <= 0 
        disp('Maximum running time for optimization procedure must be positive. Using default: 1000 s.');
        MAXTIME = 1000;
    end
else
    disp('Maximum running time for optimization procedure not specified. Using default: 1000 s.');
    MAXTIME = 1000;
end 


%%
[demEst,fObjFun] = ubo_data(data,MAXTIME);
demEst = demEst';

%save(output_filename, 'demEst', '-ascii');

end

% ubo procedure based on the comon data format
function [demEst,fObjFun] = ubo_data(data,MAXTIME)


% get data necessary for the SDA 
[~, cpuUtil, ~, ~, rAvgTimes, avgTput] = parseDataFormat(data);

a = isnan(cpuUtil);
if sum(a) > 0 
    disp('NaN values found for CPU Utilization. Removing NaN values.');
    cpuUtil = cpuUtil(a == 0);
    rAvgTimes = rAvgTimes(a == 0,:);
    avgTput = avgTput(a == 0,:);
end

a = sum(avgTput,2) == 0;
if sum(a) > 0 
    disp('Removing sampling intervals with zero throughput for all request types.');
    cpuUtil = cpuUtil(a == 0);
    rAvgTimes = rAvgTimes(a == 0,:);
    avgTput = avgTput(a == 0,:);
end


%% number of resources
M = 1;
%% number of classes
R = size(rAvgTimes,2);

beta = repmat(1./(1-cpuUtil),1,R);

%% initial point
% x0(r) is the mean service demand of class r (visits are assumed unitary)
x0 = rand(1,R).*max(rAvgTimes); % randomize service demand in [0,max(avgRTime)] for each class
%% options
options = optimset();
options.Display = 'off';
options.LargeScale = 'off';
options.MaxIter =  1e10;
options.MaxFunEvals = 1e10;
options.MaxSQPIter = 5000;
options.TolCon = 1e-8;
options.Algorithm = 'interior-point';
options.OutputFcn =  @outfun;

XLB = x0*0 + options.TolCon; % lower bounds on x variables
XUB = max(rAvgTimes); % upper bounds on x variables

T0 = tic; % needed for outfun

%% optimization program
N = size(cpuUtil,1); % number of experiments= size(cpuUtil,1); % number of experiments
epsi = cpuUtil; 
deltaj = cpuUtil;
w = avgTput./(sum(avgTput,2)*ones(1,R));
[demEst, fObjFun]=fmincon(@objfun,x0,[],[],[],[],XLB,XUB,[],options);




    function f = objfun(x)
        d = repmat(x,N,1);
        epsi = sum(d.*avgTput,2) - cpuUtil;
        deltaj = d.*beta - rAvgTimes;
        f = 0;
        for i=1:R
            f = f + w(i).*deltaj(i).^2; 
        end
        for i=1:M, f = f + epsi(i).^2; end
    end

    function stop = outfun(x, optimValues, state)
        stop = false;
        if strcmpi(state,'iter')
            if toc(T0)>MAXTIME
                fprintf('Time limit reached. Aborting.\n');
                stop = true;
            end
        end
    end

end
