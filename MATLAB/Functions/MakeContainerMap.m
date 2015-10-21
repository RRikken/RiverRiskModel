function [ WaterContainerMap ] = MakeContainerMap( WaterContainerMap,  ahn100_gem, AreaSize )
%MAKECONTAINERMAP Summary of this function goes here
%   Detailed explanation goes here
[ Rows, Columns ] = size(WaterContainerMap);
for Row = 1: Rows
    for Column = 1 : Columns
        if isnan(ahn100_gem(Row, Column)) == 0
            WaterContainerMap(Row, Column) = WaterContainer(Row, Column, ahn100_gem(Row, Column), AreaSize);
        end
    end
end

for Row = 1: Rows
    for Column = 1 : Columns
        if isnan(ahn100_gem(Row, Column)) == 0
            if Row - 1 > 0
                if isobject(WaterContainerMap(Row - 1, Column)) && isnan(WaterContainerMap(Row - 1, Column).RowPosition) == 0
                    WaterContainerMap(Row, Column).NeighbourAbove = WaterContainerMap(Row - 1, Column);
                else
                    WaterContainerMap(Row, Column).NeighbourAbove = NaN;
                end
            else
                WaterContainerMap(Row, Column).NeighbourAbove = NaN;
            end
            if Column - 1 > 0
                if isobject(WaterContainerMap(Row, Column - 1)) && isnan(WaterContainerMap(Row, Column - 1).RowPosition) == 0
                    WaterContainerMap(Row, Column).NeighbourLeft = WaterContainerMap(Row, Column - 1);
                else
                    WaterContainerMap(Row, Column).NeighbourLeft = NaN;
                end
            else
                WaterContainerMap(Row, Column).NeighbourLeft = NaN;
            end
            if Row + 1 <= Rows
                if isobject(WaterContainerMap(Row + 1, Column)) && isnan(WaterContainerMap(Row + 1, Column).RowPosition) == 0
                    WaterContainerMap(Row, Column).NeighbourBelow = WaterContainerMap(Row + 1, Column);
                else
                    WaterContainerMap(Row, Column).NeighbourBelow = NaN;
                end
            else
                WaterContainerMap(Row, Column).NeighbourBelow = NaN;
            end
            if Column + 1 <= Columns
                if isobject(WaterContainerMap(Row, Column + 1)) && isnan(WaterContainerMap(Row, Column + 1).RowPosition) == 0
                    WaterContainerMap(Row, Column).NeighbourRight = WaterContainerMap(Row, Column + 1);
                else
                    WaterContainerMap(Row, Column).NeighbourRight = NaN;
                end
            else
                WaterContainerMap(Row, Column).NeighbourRight = NaN;
            end
        end
    end
end

end

