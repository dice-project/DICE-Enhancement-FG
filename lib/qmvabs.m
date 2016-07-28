function [QN]=qmvabs(L,N,Z,tol,maxiter,QN)
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
    err=(abs(QN-QN_1) - tol*QN_1);
    if max(err) <= 0
        break
    end
end
end
