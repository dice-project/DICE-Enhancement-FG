function metric = data_validation(metric,dicefg_disp)
expectednRows = 11; % expected number of rows in data file
[nRows,nColumns] = size(metric.ResData);
if nColumns ~= (metric.NumClasses+1)*metric.NumResources
    error('Input files are inconsistent, not enough classes or resources in dataset.');
    exit
end
if nRows<expectednRows
    dicefg_disp(0,'Data does not include all rows. Adding empty rows.')
    for i=nRows+1:expectednRows
        for j=1:nColumns
            metric.ResData{i,j}=[];
        end
    end
end
end