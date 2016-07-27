function [D,confint] = est_qmle( data, qlSample, nbJobs, thinkTime, data_needed )
nbClasses = size(data,2) - 1;
nbNodes = 2;

if ~exist('nbJobs','var')
    nbJobs = zeros(1,nbClasses);
end

if ~exist('data_needed','var')
    data_needed = 0;
end

[prob_nbCustomer, nbJobs, ~, nSamples] = analyseData( data, nbJobs, nbClasses, nbNodes, data_needed);

for i = 1:nbClasses
    Q(1,i)= sum(prob_nbCustomer(:,nbClasses+i).*prob_nbCustomer(:,end));
end

if ~exist('thinkTime','var')
    for i = 1:nbClasses
        thinkTime(1,i)= nbJobs(i)/mean(data{6,i})-mean(data{5,i});
    end
end

D = mleApprox( Q, nbNodes-1, nbClasses, nbJobs, thinkTime );

try
    confint = confidence_interval( D, nbJobs, thinkTime, Q, 1.96, qlSample );
    disp('Confidence interval for each demand')
catch
    disp('Confidence interval computation failed');
end

end


function I = fisher_information(L,N,Z,n,samples)
Q = amvabs(L,N,Z);
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
                QP = qmva(LP,NP,Z);
                %[~,QP] = aql(LP,NP,Z);
                if k == r && h == s
                    I(index_r,index_c) = (Q(k,h)*(QP(k+1,h)+QP(1,h)-Q(k,h))+n(k,h))/L(k,h)^2*samples;
                    %I(index_r,index_c) = (Q(k,h)-n(k,h))/L(k,h)^2+var_n(k,h)/L(k,h)^2;
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

function [ theta ] = mleApprox( Q, M, R, K, Z )

theta = zeros(M,R);
for i = 1:M
    for j = 1:R
        theta(i,j) = Q(i,j)/(K(j)-sum(Q(:,j),1))*Z(j)/(1+sum(Q(i,:),2)-Q(i,j)/K(j));
    end
end

end

function [XN,QN,UN]=amvabs(L,N,Z,tol,maxiter,QN)
if nargin<4
    tol = 1e-6;
end
if nargin<5
    maxiter = 1000;
end
[M,R]=size(L);
if nargin <= 5
    QN=zeros(M,R);
    for r=1:R
        QN(min(find(L(:,r))),r)=N(r);
    end
end
%XN=0;
XN=zeros(1,R);
CN=zeros(M,R);
for it=1:maxiter
    QN_1 = QN;
    for r=1:R
        for i=1:M
            CN(i,r) = L(i,r);
            for s=1:R
                if s~=r
                    CN(i,r) = CN(i,r) + L(i,r)*QN(i,s);
                else
                    CN(i,r) = CN(i,r) + L(i,r)*QN(i,r)*(N(r)-1)/N(r);
                end
            end
        end
        XN(r) = N(r)/(Z(r)+sum(CN(:,r)));
    end
    for r=1:R
        for i=1:M
            if L(i,r) == 0
                QN(i,r) = 0;
            else
                QN(i,r) = XN(r)*CN(i,r);
            end
        end
    end
    for r=1:R
        for i=1:M
            UN(i,r) = XN(r)*L(i,r);
        end
    end
    err=(abs(QN-QN_1) - tol*QN_1);
    if max(err) <= 0
        break
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
        exit
    end
end

for i = 1:M
    for j = 1:R
        index = (i-1)*R+j;
        ci(i,j) = c*inv_I(index,index)^(1/2);
    end
end

end
