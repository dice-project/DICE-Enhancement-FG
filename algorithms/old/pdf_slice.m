 function [result] = pdf_slice(alg,interval,theta,nbJobs,think_time,testset,nbClasses,nbNodes,LV,sumA,logG)        
    
    if sum(theta < 0) > 0
        result = -inf;
        return;
    end
    
    theta = reshape(theta,nbClasses,nbNodes-1)';
    
    if strcmp(alg,'TE') && exist('logG','var') == 0
        logG = approLogG([think_time;theta],nbJobs,interval);
    end
    %logG = log(gmva(theta,nbJobs,think_time));
    
    result = 0;
    n_node = zeros(size(testset,1),nbNodes);
    for j = 2:nbNodes
        n_node(:,j) = sum(testset(:, nbClasses*j-nbClasses+1:nbClasses*j),2);
    end
    B=feval(@(x) LV(x+1), n_node(:,2:nbNodes));
    result = result + sum(B(:));
    
    y = [log(think_time+eps);log(theta+eps)];
    temp = reshape(y',nbClasses*nbNodes,1);
    
    result = result + sum(testset*temp);
    
    result = result - logG*size(testset,1);
    
    result = result - sumA;
 end
