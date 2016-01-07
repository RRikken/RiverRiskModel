function [ WaterContents, WaterLevelMap ] = BuildStructureForArea( BottomHeightMap )
%BUILDSTRUCTUREFORAREA Summary of this function goes here
%   Detailed explanation goes here
[ Rows, Columns ] = size(BottomHeightMap);
%%PreAllocate structure by assigning last value with NaN
            WaterLevelMap(1:Rows, 1:Columns) = NaN;
            WaterContents(1:Rows, 1:Columns) = NaN;

for Row = 1 : Rows
    for Column = 1 : Columns
        if isnan(BottomHeightMap(Row, Column)) == 0
            WaterContents(Row, Column) = 0;
            WaterLevelMap(Row, Column) = BottomHeightMap(Row, Column);
        else
            WaterContents(Row, Column) = NaN;
            WaterLevelMap(Row, Column) = NaN;
        end
    end
end
end