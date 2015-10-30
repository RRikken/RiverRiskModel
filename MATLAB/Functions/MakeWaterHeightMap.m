function [ WaterHeightMap ] = MakeWaterHeightMap( ObjectWaterMap )
%MAKEWATERHEIGHTMAP Summary of this function goes here
%   Detailed explanation goes here

[ RowsWaterMap, ColumnsWaterMap ] = size(ObjectWaterMap);
WaterHeightMap = zeros(RowsWaterMap, ColumnsWaterMap);
for Row = 1:RowsWaterMap
    for Column = 1:ColumnsWaterMap
        WaterHeightMap(Row, Column) = ObjectWaterMap(Row, Column).WaterContents;
    end
end
end