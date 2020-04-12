function [XN,QN]=amvabs(L,N,Z,tol,maxiter,QN)
if nargin<4
    tol = 1e-6;
end
if nargin<5
    maxiter = 1000;
end
[M,R]=size(L);
if nargin <= 5
    QN=repmat(N,M,1)/M;
end
XN=zeros(1,R);
CN = zeros(M,1);
for it=1:maxiter
    QN_1 = QN;
    for r=1:R
        Ctot = Z(r);
        for i=1:M
            CN(i) = L(i,r) - L(i,r)*QN(i,r)/N(r);
            for s=1:R
                CN(i) = CN(i) + L(i,r)*QN(i,s);
            end
            Ctot = Ctot + CN(i);
        end        
        XN(r) = N(r)/Ctot;
        for i=1:M
            QN(i,r) = XN(r)*CN(i);
        end
    end
    if max(max(abs(QN-QN_1)./QN_1)) < tol
        break
    end
end
end