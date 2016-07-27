function C=circul(c)
if length(c)==1
    if c==1
        C=1;
    else
        v=zeros(1,c);
        v(end)=1;
        C=circul(v);
    end
    return
end
n=length(c);
I=eye(n);
R=I(1:n,[2:n 1]);
C=zeros(n);
for t=0:n-1
    C=C+c(1+t)*R^t;
end

end