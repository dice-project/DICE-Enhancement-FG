function [value, logG_current, range_size_dim] = gibbsSamplerSimple(alg,think_time,theta,testset,index,nbNodes,nbClasses,nbJobs,logG_initial,interval,range_size,LV,sumA)
   
    range = (0:interval:range_size);
    N = length(range);
    
    if strcmp(alg,'TE')
        x = zeros(nbNodes,nbClasses);
        x(1,:) = think_time;
        for i = 1:nbNodes-1
            x(i+1,:) = theta(i*nbClasses+1-nbClasses:i*nbClasses);
        end

        index_i = floor((index-1)/nbClasses)+2;
        index_j = index-(index_i-2)*nbClasses;

        logG = zeros(1,N);

        [~,QN]=amvabs(x(2:end,:),nbJobs,x(1,:));

        index_previous = find(range==theta(index));
        logG(index_previous) = logG_initial;

        for i = index_previous-1:-1:1
            x(index_i,index_j) = range(i+1);
            %[~,QN]=aql(x(2:end,:),nbJobs,x(1,:),interval);
            [~,QN]=amvabs(x(2:end,:),nbJobs,x(1,:),interval,1000,QN);
            if 1+QN(index_i-1,index_j)/(range(i+1)+eps)*-interval < 0
                logG(i) = logG(i+1);
            else
                logG(i) = logG(i+1) + log(1+QN(index_i-1,index_j)/(range(i+1)+eps)*-interval);
            end
        end

        x(index_i,index_j) = theta(index);
        [~,QN]=amvabs(x(2:end,:),nbJobs,x(1,:));

        for i = index_previous+1:N
            x(index_i,index_j) = range(i-1);
            %[~,QN]=aql(x(2:end,:),nbJobs,x(1,:),interval);
            [~,QN]=amvabs(x(2:end,:),nbJobs,x(1,:),interval,1000,QN);
            if 1+QN(index_i-1,index_j)/(range(i-1)+eps)*interval < 0
                logG(i) = logG(i-1);
            else
                logG(i) = logG(i-1) + log(1+QN(index_i-1,index_j)/(range(i-1)+eps)*interval);
            end
        end
    end

    log_prob = zeros(1,N);
    for i = 1:N
        theta(index) = range(i);
        if strcmp(alg,'TE')
            log_prob(i) = sum(testset(:,index+nbClasses))*log(range(i))-logG(i)*size(testset,1);
            %log_prob(i) = pdf_slice(alg,method,interval,tol,theta,nbJobs,think_time,testset,nbClasses,nbNodes,LV,sumA,logG(i));  
        end
        if strcmp(alg,'MCI')
            log_prob(i) = pdf_slice(alg,interval,theta,nbJobs,think_time,testset,nbClasses,nbNodes,LV,sumA);
        end
    end
    log_prob = log_prob-max(log_prob);
    
    prob = exp(log_prob);
    prob = prob/sum(prob);
    
    cum_prob = cumsum(prob);
    rand_variable = rand(1);
    index_prob = find(rand_variable<cum_prob);
    
%    if strcmp(alg,'TE')
        range_size_dim = find(cum_prob > 1-1e-10, 1, 'first');
        range_size_dim = range(range_size_dim)*2;
%     end
%     if strcmp(alg,'MCI')
%         range_size_dim = 0;
%     end
    
    if isempty(index_prob)
        value = theta(index);
        if strcmp(alg,'TE')
            logG_current = logG_initial;
        end
    else
        value = range(index_prob(1));
        if strcmp(alg,'TE')
            logG_current = logG(index_prob(1));
        end
    end
    
    if strcmp(alg,'MCI')
        logG_current = 0;
    end
end