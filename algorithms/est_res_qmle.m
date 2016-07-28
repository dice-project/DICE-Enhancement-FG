function [theta,confint] = est_res_qmle( metric,flags,dicefg_disp )
[extDelay, jobPop] = est_res_extdelay(metric,flags,dicefg_disp);
qlSamples = Inf;
% determine probability of each sampling period
for r=1:metric.NumClasses
    weightTS{r} = diff(get_data(metric,'ts', metric.ResIndex, r),1);
    weightTS{r} = weightTS{r}./sum(weightTS{r});
    qlenAvgSamples = get_data(metric,'qlenAvg', metric.ResIndex, r);
    % we take the worst case where the number of samples is the number of samples of the averages
    qlSamples = min(qlSamples, length(qlenAvgSamples));
    % obtain overall average by weighted sum of the avg tput and avg rt samples
    avgQlen(r) = sum(weightTS{r}.*qlenAvgSamples,1);
end

theta = zeros(1,metric.NumClasses);
for j = 1:metric.NumClasses
    theta(j) = avgQlen(j)/(jobPop(j)-avgQlen(j)) * extDelay(j)/(1+sum(avgQlen)-avgQlen(j)/jobPop(j));
end

criticalValue = 1.96; % 95-percent confidence
confint = confidence_interval( theta, jobPop, extDelay, avgQlen, criticalValue, qlSamples );
end

function I = fisher_information(L,N,Z,n,samples)
Q = qmvabs(L,N,Z);
[M,R] = size(L);
for k = 1:M
    for h = 1:R
        for r = 1:M
            LP = [L(k,:);L];
            for s = 1:R
                index_r = (k-1)*R+h;
                index_c = (r-1)*R+s;
                
                NP = N;
                NP(h) = NP(h) - 1;
                QP = qmvabs(LP,NP,Z);
                if k == r && h == s
                    I(index_r,index_c) = (Q(k,h)*(QP(k+1,h)+QP(1,h)-Q(k,h))+n(k,h))/L(k,h)^2*samples;
                else
                    if k == r
                        I(index_r,index_c) = Q(k,h)/L(k,h)/L(r,s)*(QP(r+1,s)+QP(1,s)-Q(r,s));
                    else
                        I(index_r,index_c) = Q(k,h)/L(k,h)/L(r,s)*(QP(r+1,s)-Q(r,s));
                    end
                    I(index_r,index_c) = I(index_r,index_c)*samples;
                end
                
            end
        end
    end
end
end

function [ci,flag] = confidence_interval( L, N, Z, n, c, samples )
[M,R] = size(L);
ci = zeros(M,R);
I = fisher_information(L,N,Z,n,samples);
inv_I = inv(I);
A = -I;
eig_A = eig(A);
flag = 0;
for i = 1:rank(A)
    if eig_A(i) > 0
        flag = 1;
        return
    end
end
for i = 1:M
    for j = 1:R
        index = (i-1)*R+j;
        ci(i,j) = c*inv_I(index,index)^(1/2);
    end
end
end
