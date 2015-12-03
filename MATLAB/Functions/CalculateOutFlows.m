function [ FloodedCellsMap, WaterLevelMap, WaterContentMap ] = CalculateOutFlows( WaterLevelMap, WaterContentMap, RowPosition, ColumnPosition, FloodedCellsMap, AreaSize, BottomHeightMap )

persistent SurroundingWaterLevelsCache SurroundingCellsCache TotalRows TotalColumns

if isempty(TotalRows) || isempty(TotalColumns)
    [ TotalRows, TotalColumns ] = size(WaterContentMap);
end
if isempty(SurroundingCellsCache)
    SurroundingCellsCache = zeros(4,2);
end
if isempty(SurroundingWaterLevelsCache)
    SurroundingWaterLevelsCache = [1 NaN; 2 NaN; 3 NaN; 4 NaN; 5 NaN];
end

SurroundingWaterLevels = SurroundingWaterLevelsCache;
SurroundingCells = SurroundingCellsCache;

SurroundingCells(1:4,1) = RowPosition;
SurroundingCells(1:4,2) = ColumnPosition;
SurroundingCells = SurroundingCells + [ -1 0; 0 -1; 0 1; 1 0; ];

WaterContents = zeros(1,4);

for ind = 1 : 4
    WaterContents(ind) =  WaterContentMap(SurroundingCells(ind,1), SurroundingCells(ind,2));
end

[ SurroundingWaterlevels, WaterLevelMap ] = CheckSurroundingWaterLevels(WaterLevelMap, BottomHeightMap, RowPosition, TotalRows, ColumnPosition, TotalColumns, SurroundingWaterLevels);

[~, order] = sort(SurroundingWaterlevels(:, 2));
SurroundingWaterlevels = SurroundingWaterlevels(order, :);

[WaterOutflowVolumes, WaterContentMap ] = DetermineOutflows(SurroundingWaterlevels, WaterContentMap, AreaSize, RowPosition, ColumnPosition);
[ WaterContentMap, WaterLevelMap ] = PutOutflowIntoArea(  WaterContentMap, WaterLevelMap, RowPosition, TotalRows, ColumnPosition, TotalColumns, WaterOutflowVolumes );
[ WaterLevelMap ] = UpdateWaterLevelMap(WaterLevelMap, WaterContentMap, BottomHeightMap, RowPosition, ColumnPosition, AreaSize);

if (WaterOutflowVolumes(1,2) + WaterOutflowVolumes(2,2) + WaterOutflowVolumes(3,2) + WaterOutflowVolumes(4,2)) > 0.00000001
    for ind = 1 : 4
        if WaterOutflowVolumes(ind,2) > 0.00000001 && WaterContents(ind) < 0.00000001
            SelectedCell = [ SurroundingCells(ind,1) SurroundingCells(ind,2) ];
            
            n=floor(log10(SelectedCell(2)));
            UniqueID = 10^(n+1)*SelectedCell(1) + SelectedCell(2);
            
            if isKey(FloodedCellsMap, UniqueID) == 0
                FloodedCellsMap(UniqueID) = SelectedCell;
            end
        end
    end
end

end