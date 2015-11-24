function [ WaterOutflowVolumes, FloodedCellsMap, WaterLevelMap, WaterContentMap ] = CalculateOutFlows( WaterLevelMap, WaterContentMap, RowPosition, ColumnPosition, FloodedCellsMap, AreaSize, BottomHeightMap )

SurroundingCells = zeros(4,2);
SurroundingCells(1:4,1) = RowPosition;
SurroundingCells(1:4,2) = ColumnPosition;
SurroundingCells = SurroundingCells + [ -1 0; 0 -1; 0 1; 1 0; ];
SurroundingWaterLevels = [1 NaN; 2 NaN; 3 NaN; 4 NaN; 5 NaN];
[ TotalRows, TotalColumns ] = size(WaterContentMap);
WaterContents = zeros(1,4);

for ind = 1 : 4
    WaterContents(ind) =  WaterContentMap(SurroundingCells(ind,1), SurroundingCells(ind,2));
end

[ SurroundingWaterlevels, WaterLevelMap ] = CheckSurroundingWaterLevels(WaterLevelMap, BottomHeightMap, RowPosition, TotalRows, ColumnPosition, TotalColumns, SurroundingWaterLevels);
[~, order] = sort(SurroundingWaterlevels(:, 2));
SurroundingWaterlevels = SurroundingWaterlevels(order, :);
[WaterOutflowVolumes, WaterContentMap, WaterLevelMap ] = DetermineOutflows(SurroundingWaterlevels, WaterContentMap, WaterLevelMap, BottomHeightMap, AreaSize, RowPosition, ColumnPosition);

if sum(WaterOutflowVolumes(1:4,2)) > 0.00000001
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

function [ WaterOutflowVolumes, WaterContentMap, WaterLevelMap ] = DetermineOutflows( SortedWaterLevels, WaterContentMap, WaterLevelMap, BottomHeightMap, AreaSize, RowPosition, ColumnPosition )
    ContainerVolume = zeros(1,5);
    for ind = 1 : 4
        ContainerVolume(ind) = (SortedWaterLevels(ind + 1, 2) - SortedWaterLevels(ind, 2))  * AreaSize * ind;
    end
    ContainerVolume(5) = inf;

    WaterVolume = WaterContentMap(RowPosition, ColumnPosition);
    WaterContentMap(RowPosition, ColumnPosition) = 0;
    WaterLevelMap(RowPosition, ColumnPosition) = BottomHeightMap(RowPosition, ColumnPosition);
    
    WaterOutflowVolumes = zeros(5,2);
    WaterOutflowVolumes(:, 1) = SortedWaterLevels(:, 1);
    WaterOutflowVolumes(:, 2) = [0; 0; 0; 0; 0];
    if WaterVolume <=  ContainerVolume( 1 )
        WaterOutflowVolumes( 1, 2 ) = WaterVolume;
        WaterVolume = 0;
    elseif WaterVolume <=  sum(ContainerVolume( 1 : 2 )) && WaterVolume ~= 0
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + (WaterVolume - ContainerVolume( 1 )) / 2;
        WaterOutflowVolumes( 2, 2 ) = (WaterVolume - ContainerVolume( 1 )) / 2;
        WaterVolume = 0;
    elseif WaterVolume <= sum(ContainerVolume( 1 : 3 )) && WaterVolume ~= 0
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + (WaterVolume - sum(ContainerVolume( 1 : 2 ))) / 3;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + (WaterVolume - sum(ContainerVolume( 1 : 2 ))) / 3;
        WaterOutflowVolumes( 3, 2 ) = (WaterVolume - sum(ContainerVolume( 1 : 2 ))) / 3;
        WaterVolume = 0;
    elseif WaterVolume <=  sum(ContainerVolume( 1 : 4 )) && WaterVolume ~= 0
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + (WaterVolume - sum(ContainerVolume( 1 : 3 ))) / 4;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + (WaterVolume - sum(ContainerVolume( 1 : 3 ))) / 4;
        WaterOutflowVolumes( 3, 2 ) = ContainerVolume( 3 ) / 3 + (WaterVolume - sum(ContainerVolume( 1 : 3 ))) / 4;
        WaterOutflowVolumes( 4, 2 ) = (WaterVolume - sum(ContainerVolume( 1 : 3 ))) / 4;
        WaterVolume = 0;
    elseif WaterVolume <=  sum(ContainerVolume( 1 : 5 )) && WaterVolume ~= 0
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + ContainerVolume( 4 ) / 4 + (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + ContainerVolume( 4 ) / 4 + (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterOutflowVolumes( 3, 2 ) = ContainerVolume( 3 ) / 3 + ContainerVolume( 4 ) / 4 + (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterOutflowVolumes( 4, 2 ) = ContainerVolume( 4 ) / 4 + (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterOutflowVolumes( 5, 2 ) = (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterVolume = 0;
    elseif WaterVolume > 0.00000001 ||WaterVolume < 0.0000001
        debug
    else
        debug
    end
    
    [~, order] = sort(WaterOutflowVolumes(:, 1));
    WaterOutflowVolumes = WaterOutflowVolumes(order, :);
    
end