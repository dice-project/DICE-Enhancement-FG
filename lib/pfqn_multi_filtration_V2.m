function [MAP,SS] = pfqn_multi_filtration_V2(mu,N,P,muZ,tagStat,tagCls,V)
% PFQN_MULTI_FILTRATION_V2 computes the associated MAP and the state space 
% for a closed queueing network, filtering out the service completions
% of a tagged class in a tagged stations
% mu:       M x R vector containing the processing rates in each of the
%           M nodes in the network for each of the R classes of customers
% P:        routing matrices for each job type
% tagStat:  station to filter (events that contribute to D1)
% tagCls:   class to filter (events that contribute to D1)
% V:        number of servers in the tagged processing node (works for one only)
%
% Copyright (c) 2012-2016, Imperial College London 
% All rights reserved.


[M,R]=size(mu);

if sum(muZ) > 0
    SS = ssg_closed_multi(M+1,N); % state space of a multi classs closed 
                                  % QN with M+1 nodes and N
                                  % customers for each class (the sum of
                                  % the entries of N provides the total
                                  % number of customers in the network
                                  % For a given row/state, entry (r-1)*nCOL + i
                                  % contains the number of jobs of type r
                                  % in node i
                                  % First R entries contain distribution of
                                  % type-1 jobs in the M+1 nodes - last
                                  % node is the thinking node (M+1)
    nCOL = M+1;%number of nodes in the queue
else
    SS = ssg_closed_multi(M,N); %this is the case with no arrivals from a source
                                %node with a given thinking time
    nCOL = M;
end

SSZ = size(SS,1);
Q = sparse(SSZ,SSZ);
D1 = sparse(SSZ,SSZ);
n = zeros(1,nCOL);
for s=1:size(SS,1)%for each state
    % source state
    st = SS(s,:);
    for i=1:nCOL
        n(i)=0;
        for r=1:R
            n(i)=n(i)+sum(st((r-1)*nCOL + i));            
        end %at the end of this loop n is the number of jobs in each node 
            %disregarding the types
        n(i)=max([n(i),1]); % adjusts number to use this to determine actual rate in PS nodes
    end
    for r=1:R %for each job type
        for i=1:nCOL % for each node
            if st((r-1)*nCOL + i) > 0 %if there is at least one type-r job in node i
                for j=1:nCOL %for each possible destination node
                    if P{r}(i,j)>0 %is node j reachable from node i by this job type (r)
                        % destination state
                        dst = st;
                        dst((r-1)*nCOL + i) = dst((r-1)*nCOL + i) - 1;
                        dst((r-1)*nCOL + j) = dst((r-1)*nCOL + j) + 1; %creates dest state from current one
                        d = matchrow(SS,dst); %finds row index for state dst in SS array
                        if i <= M % queue - actual processing nodes, not source node
                            if n(i) <= V %less jobs in the node than processors 
                                if i == tagStat && r == tagCls
                                    D1(s,d) = D1(s,d) + P{r}(i,j) * mu(i,r);
                                    % adds transition rate to D1. the rate
                                    % includes the routing probabilities, the
                                    % service rate in vector mu, the number of
                                    % jobs present in the station and divides
                                    % by the total number of jobs to account
                                    % for PS behavior
                                end
                                Q(s,d) = Q(s,d) + P{r}(i,j) * mu(i,r);
                                Q(s,s) = Q(s,s) - P{r}(i,j) * mu(i,r);
                            else
                                if i == tagStat && r == tagCls
                                    D1(s,d) = D1(s,d) + P{r}(i,j) * mu(i,r) * V * st((r-1)*nCOL + i)/n(i);
                                    % adds transition rate to D1. the rate
                                    % includes the routing probabilities, the
                                    % service rate in vector mu, the number of
                                    % jobs present in the station and divides
                                    % by the total number of jobs to account
                                    % for PS behavior
                                end
                                Q(s,d) = Q(s,d) + P{r}(i,j) * mu(i,r) * st((r-1)*nCOL + i)*V/n(i);
                                Q(s,s) = Q(s,s) - P{r}(i,j) * mu(i,r) * st((r-1)*nCOL + i)*V/n(i);
                            end
                        else % delay - source node
                            if i == tagStat && r == tagCls  % if the event is from the tagged class and from
                                                            % the tagged station, mark if and include it in D1
                                D1(s,d) = D1(s,d) + P{r}(i,j) * muZ(r) * st((r-1)*nCOL + i);
                            end
                            Q(s,d) = Q(s,d) + P{r}(i,j) * muZ(r) * st((r-1)*nCOL + i); 
                            %add transition rate to generator matrix. the
                            %rate considers the routing probability, the
                            %rate (arrival in this case) and the number of
                            %jobs in the station
                            Q(s,s) = Q(s,s) - P{r}(i,j) * muZ(r) * st((r-1)*nCOL + i);
                            %add transition rate to diagonal entry of
                            %generator matrix
                        end
                    end
                end
            end
        end
    end
end
MAP = {Q-D1,D1};
end