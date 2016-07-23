function [ think_time, R, X ] = estimateZ( data, N0 )

nbClasses = size(data,2)-1;
think_time = zeros(1,nbClasses);
for k = 1:nbClasses
    think_time(k) = N0(k)/mean(data{6,k});
    R(k) = mean(data{5,k});
    X(k) = mean(data{6,k});
end

end

