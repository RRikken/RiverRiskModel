function [ SurroundingWaterLevels, WaterLevelMap ] = CheckSurroundingWaterLevels(WaterLevelMap, BottomHeightMap, RowPosition, TotalRows, ColumnPosition, TotalColumns, SurroundingWaterLevels)

SurroundingWaterLevels(5,2) = BottomHeightMap(RowPosition, ColumnPosition);

if RowPosition - 1 >= 1
    SurroundingWaterLevels(1,2) = WaterLevelMap(RowPosition - 1, ColumnPosition);
end
if ColumnPosition - 1 >= 1
    SurroundingWaterLevels(2,2) = WaterLevelMap(RowPosition, ColumnPosition - 1);
end
if ColumnPosition + 1 <= TotalColumns
    SurroundingWaterLevels(3,2) = WaterLevelMap(RowPosition, ColumnPosition + 1);
end
if RowPosition + 1 <= TotalRows
    SurroundingWaterLevels(4,2) = WaterLevelMap(RowPosition + 1, ColumnPosition);
end
end