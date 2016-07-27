function demand = gibbs(data,nbCores,tol)

if exist('tol','var') == 0
    tol = 10^-3;
end 

alg = 'TE'; % or MCI

data_needed = 200000;
likelihood_sample = 5000;
nbSamples = 2000;

nbClasses = size(data,2)-1;
nbNodes = 2;
nbJobs = zeros(1,nbClasses);
[prob, nbJobs, N0] = analyseData(data, nbJobs, nbClasses, nbNodes, data_needed);

usedCores = 0;
for k = 1:size(prob,1)
    if (sum(prob(k,nbClasses+1:nbClasses*2)) > nbCores)
        usedCores = usedCores + nbCores*prob(k,end);
    else
        usedCores = usedCores + sum(prob(k,nbClasses+1:nbClasses*2))*prob(k,end);
    end
end
usedCores = usedCores/(1-prob(end,end));

think_time = zeros(1,nbClasses);
for k = 1:nbClasses
    think_time(k) = (nbJobs(k)-N0(k))/mean(data{6,k});
end

range_size = ones(1,nbClasses*(nbNodes-1));

%         testset = [];
%         for k = 1:size(prob,1)
%             testset = [testset; repmat(prob(k,1:(nbClasses*nbNodes)),round(prob(k,end)*likelihood_sample),1)];
%         endinterval

cum_prob = cumsum(prob(:,nbClasses*nbNodes+1));
testset = zeros(likelihood_sample,nbClasses*nbNodes);
for k = 1:likelihood_sample
    uni_value = rand(1);
    index = find(uni_value<cum_prob);
    testset(k,:) = prob(index(1),1:(nbClasses*nbNodes));
end

LV(1) = 0; %log(0!)
LV(2) = 0; %log(1!)
for k = 3:sum(nbJobs)+1
    LV(k) = LV(k-1)+log(k-1);
end

A=feval(@(x) LV(x+1), testset);
sumA = sum(A(:));

initial = zeros(1,nbClasses*nbNodes-nbClasses);

logG_initial = sum(nbJobs.*log(think_time));
for k = 1:nbClasses
    logG_initial = logG_initial - sum(log(1:nbJobs(k)));
end

smpl = zeros(nbSamples,nbClasses*(nbNodes-1));
sample_index = 0;

for k = 1:round(nbSamples/50)
    for s = 1:50
        sample_index = sample_index + 1;
        for h = 1:nbClasses*(nbNodes-1)
            if sample_index==1
                theta = [smpl(sample_index,1:h-1),initial(h:end)];
            else
                theta = [smpl(sample_index,1:h-1),smpl(sample_index-1,h:end)];
            end
            
            [smpl(sample_index,h), logG_initial, range_size_dim]= gibbsSamplerSimple(alg,think_time,theta,testset,h,nbNodes,nbClasses,nbJobs,logG_initial,tol,range_size(h),LV,sumA);
            
            range_size(h) = range_size_dim*2;

        end
    end
    
    if  k == 2
        demand_old = mean(smpl(51:sample_index,:));
    elseif k > 2
        demand_now = mean(smpl((k-1)*50+1:sample_index,:));
        demand_now = demand_now/(k+1)+demand_old/(k+1)*k;
        if mean(abs((demand_now-demand_old)./demand_old)) < tol
            nbSample =  sample_index-1;
            N = round(nbSample/2)+1;
            demand = mean(smpl(N:nbSample,:)*usedCores);
            return
        else
            demand_old = demand_now;
        end
    end
    
end
nbSample =  sample_index-1;
N = round(nbSample/2)+1;
demand = mean(smpl(N:nbSample,:)*usedCores);

