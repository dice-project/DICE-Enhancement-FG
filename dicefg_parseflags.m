function flags = dicefg_parseflags(metric)
% numServers
ret = regexp(metric.Flags,'numServers\s*=\s*(\d+)','tokens','once');
if isempty(ret) flags.('numServers') = 1; else flags.('numServers') = str2num(ret{1}); end
% warmUp
ret = regexp(metric.Flags,'warmUp\s*=\s*(\d+)','tokens','once');
if isempty(ret) flags.('warmUp') = 0; else flags.('warmUp') = str2num(ret{1}); end
end