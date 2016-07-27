function feasiblerows = matchrow(Matrix, row)
% feasiblerows = matchrow(Matrix, row)
% match unique row in Matrix
feasiblerows=1:size(Matrix,1);
for col=1:length(row)
    A=Matrix(feasiblerows,col)==row(col);
    t=find(A);
    feasiblerows=feasiblerows(t);
    if length(feasiblerows)==1 && sum(Matrix(feasiblerows,:)==row)==size(Matrix,2)       
        return
    end
end

feasiblerows=-1;

end

