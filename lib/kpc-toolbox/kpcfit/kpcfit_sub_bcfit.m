function [E1j,E3j,f]=map_kpcfit_bispectrum(E,SCVj,G2j,BC,BCLags,MaxIterBC, MaxRunsBC)
%% optimization parameters
MaxTimeBC = 100;
NumMAPs=length(SCVj);
TOL=1e-9;
EPSTOL=10*TOL;
options = optimset('LargeScale','off', ...
    'MaxIter',MaxIterBC, ...
    'MaxFunEvals',1e10, ...
    'MaxSQPIter',500, ...
    'TolCon',TOL, ...
    'Display','off', ...
    'DiffMinChange',1e-10, ...
    'OutputFcn',@outfun);

%% other variables
NBC=norm(BC,2); % normalizing constants for bicovariances

%% truncate bicorrelations when it gets negative
tag=[];
for i=1:size(BCLags,1)
    if find(diff(BCLags(i,:))<0)
        tag(end+1,1)=i;
    end
end
BCLags(tag,:)=[];
BC(tag)=[];

E1j=E(1).^(1/NumMAPs)*ones(1,NumMAPs);
t=E(1)*rand;
fold=0;

xparamset = {}; % record all the possible x params
fset = [];   % record the objective function values for each param set
xparam_best = [];
f_best = inf;
for j = 1:NumMAPs
    E2j(j)=(1+SCVj(j))*E1j(j)^2;
    E3j(j)=(3/2+t)*E2j(j)^2/E1j(j);
end
x0=[E1j(:);E3j(:)]';

    %fprintf(1,'bcfit: maximum number of solver iterations per run is MaxIterBC = %d\n', MaxIterBC);
for i = 1:MaxRunsBC
    tstart = tic();
    %fprintf(1,'bcfit: run %d of %d ',i,MaxRunsBC);
    tic;
    numIterations = 0;
    [x,f,exitflag]=fmincon(@objfun,x0,[],[],[],[],0*x0+EPSTOL,[],@nnlcon,options);
    %fprintf(1,'(%3.3f sec, %d iter)\n',toc, numIterations);
    xparamset{end+1} = x;
    fset(1,end+1) = f;
    if f < f_best
        %        %fprintf(1,'**best**',toc);
        f_best = f;
        xparam_best = x;
    end
    %%fprintf(1,'\n',toc);
end
[v,ind] = sort(fset,2,'ascend');

[E1j,E3j]=xtopar(xparam_best);
E1j(1)=E(1)/prod(E1j(2:end));
prod(E1j);
f = f_best;

    function [E1j,E3j]=xtopar(x)
        E1j=x(1:NumMAPs);
        E3j=x((NumMAPs+1):end);
        E1j(1)=E(1)/prod(E1j(2:end));
    end
    function [c,ceq]=nnlcon(x)
        [E1j,E3j]=xtopar(x);
        c=[];
        ceq=[];
        for j=2:NumMAPs
            c(end+1)=(2+EPSTOL)*E1j(j)^2-E2j(j);    % E2j(j) > 2*E1j(j)^2
            c(end+1)=(3/2+EPSTOL)*E2j(j)^2/E1j(j)-E3j(j);
            % E3j(j) >
            % 3*E2j(j)^2/(2*E1j(j))
        end
        if SCVj(1)>1
            % if SCV for the first MMPP2 is > 1
            % add the constraint that E2 > 2*E1^2
            % and the constraint that E3 > 3*E2^2/(2*E1)
            c(end+1)=(2+EPSTOL)*E1j(1)^2-E2j(1);
            c(end+1)=(3/2+EPSTOL)*E2j(1)^2/E1j(1)-E3j(1);
        end
        temp = prod(E3j);
        temp = temp/(factorial(3))^(NumMAPs-1);
        c(end+1) = temp/E(3) -2;
        c(end+1) = 0.5 - temp/E(3);
        for j = 2:NumMAPs
            c(end+1) =  1/3*E1j(j)/(E2j(j)-2*E1j(j)^2)*E3j(j)-1/2*E2j(j)^2/(E2j(j)-2*E1j(j)^2) - 1/(1e+16);
            c(end+1) =  1e-16 - 1/3*E1j(j)/(E2j(j)-2*E1j(j)^2)*E3j(j)-1/2*E2j(j)^2/(E2j(j)-2*E1j(j)^2);
            
        end
        
    end
    function f=objfun(x)
        [E1j,E3j]=xtopar(x);
        BCj=ones(1,size(BCLags,1));
        for j=1:NumMAPs
            if j==1
                MAPj=mmpp2_fit3(E1j(1),(1+SCVj(1))*E1j(1)^2,E3j(1),G2j(1));
                if map_isfeasible(MAPj)<12
                    MAPj=map_block(E1j(1),(1+SCVj(1))*E1j(1)^2,E3j(1),G2j(1));
                end
            else
                MAPj=map_block(E1j(j),(1+SCVj(j))*E1j(j)^2,E3j(j),G2j(j));
            end
            for i=1:size(BCLags,1)
                BCj(i)=BCj(i)*(map_joint(MAPj,BCLags(i,:),[1,1,1]));
            end
        end
        f=norm(BC-BCj,2)/NBC; %rms, this is the objective function
        % for fitting the BCariance
        
        if isnan(f)
            f=2*fold;
        else
            fold=f;
        end
    end

    function stop = outfun(x,optimValues,state)
        numIterations = optimValues.iteration;
        stop = false;
        if strcmpi(state,'iter')
            if optimValues.iteration >= MaxIterBC && optimValues.iteration>1
                if ( optimValues.fval > f_best)
                    stop = true;
                end
            end
            telapsed = toc(tstart);
            if (telapsed>MaxTimeBC && optimValues.iteration > MaxIterBC)
                %fprintf('Time limit reached in moments fitting. Aborting.\n');
                stop = true;
            end
        end
    end

end
