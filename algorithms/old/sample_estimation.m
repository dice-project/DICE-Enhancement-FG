% This is a sample script that calls the demand estimation methods
%
% Copyright (c) 2012-2014, Imperial College London 
% All rights reserved.


% load a data file in the standard format
name = 'dataTestV2W4N20'; 
load(['data/',name,'.mat']);

% define number of CPUs according to the data
V = 2;

% determine the sample to analyze from the data
initSample = 501;
sampleSize = 100;
% Notice that the methods use response times and queue lengths observed at
% arrival. The standard format however does not include the queue lengths. 
% To overcome this, we assume the data comes from full trace stored in the
% standard format, and use the arrival and response times to derive the
% queue lengths at arrival time. To this end the samples are ordered by
% arrival time. After this ordering, the samples with index between
% INITSAMPLE and INITSAMPLE+SAMPLESIZE+1 are considered for analysis. 
% If the queue-lengths upon arrival are available, you can directly called
% the methods called DES_XXX, where XXX is the name of the estimation
% method (RPS/ERPS/MLPS/MINPS/FMLPS). 


%% RPS
demandEst = main_RPS(data, initSample, sampleSize, V); 
filename = ['res/RPS_', name, '_SS',int2str(sampleSize)];
save([filename,'.mat'],'demandEst');
RPS = demandEst;

%% ERPS
demandEst = main_ERPS(data, initSample, sampleSize, V); 
filename = ['res/ERPS_', name, '_SS',int2str(sampleSize)];
save([filename,'.mat'],'demandEst');
ERPS = demandEst;

%% MLPS
demandEst = main_MLPS(data, initSample, sampleSize, V); 
filename = ['res/MLPS_', name, '_SS',int2str(sampleSize)];
save([filename,'.mat'],'demandEst');
MLPS = demandEst;

%% MINPS
demandEst = main_MINPS(data, initSample, sampleSize, V); 
filename = ['res/MINPS_', name, '_SS',int2str(sampleSize)];
save([filename,'.mat'],'demandEst');
MINPS = demandEst;

%% FMLPS
demandEst = main_FMLPS(data, initSample, sampleSize, V); 
filename = ['res/FMLPS_', name, '_SS',int2str(sampleSize)];
save([filename,'.mat'],'demandEst');
FMLPS = demandEst;

res = [RPS; ERPS; MLPS; MINPS; FMLPS]