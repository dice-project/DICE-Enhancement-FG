function row = hash_metric(metricName)
switch metricName
    case 'ts' 
        row = 1;
    case 'util' 
        row = 2;
    case 'arvT' 
        row = 3;
    case 'respT' 
        row = 4;
    case 'respTAvg' 
        row = 5;
    case 'tputAvg' 
        row = 6;
    case 'depT' 
        row = 7;
    case 'qlen' 
        row = 8;
    case 'qlenAvg' 
        row = 9;
    case 'jobId' 
        row = 10;
    case 'mem' 
        row = 11;
    case 'memAvg' 
        row = 12;
end
end