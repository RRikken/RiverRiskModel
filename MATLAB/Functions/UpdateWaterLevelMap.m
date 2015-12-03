function [ WaterLevelMap ] = UpdateWaterLevelMap( WaterLevelMap, WaterContentMap, BottomHeightMap, RowPosition, ColumnPosition, AreaSize )
    WaterLevelMap(RowPosition - 1, ColumnPosition) = WaterContentMap(RowPosition - 1, ColumnPosition)/AreaSize + BottomHeightMap(RowPosition - 1, ColumnPosition);
    WaterLevelMap(RowPosition, ColumnPosition - 1) = WaterContentMap(RowPosition, ColumnPosition - 1)/AreaSize + BottomHeightMap(RowPosition, ColumnPosition - 1);
    WaterLevelMap(RowPosition, ColumnPosition + 1) = WaterContentMap(RowPosition, ColumnPosition + 1)/AreaSize + BottomHeightMap(RowPosition, ColumnPosition + 1);
    WaterLevelMap(RowPosition + 1, ColumnPosition) = WaterContentMap(RowPosition + 1, ColumnPosition)/AreaSize + BottomHeightMap(RowPosition + 1, ColumnPosition);
    WaterLevelMap(RowPosition, ColumnPosition) = WaterContentMap(RowPosition, ColumnPosition)/AreaSize + BottomHeightMap(RowPosition, ColumnPosition);
end