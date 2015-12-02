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

function [ WaterOutflowVolumes, WaterContentMap ] = DetermineOutflows( SortedWaterLevels, WaterContentMap, AreaSize, RowPosition, ColumnPosition )
    persistent ContainerVolumeCache WaterOutflowVolumesCache

    if isempty(ContainerVolumeCache)
        ContainerVolumeCache = zeros(1,5);
    end
    if isempty(WaterOutflowVolumesCache)
        WaterOutflowVolumesCache = zeros(5,2);
    end
    
    WaterOutflowVolumes = WaterOutflowVolumesCache;
    ContainerVolume = ContainerVolumeCache;
    
    for ind = 1 : 4
        ContainerVolume(ind) = (SortedWaterLevels(ind + 1, 2) - SortedWaterLevels(ind, 2))  * AreaSize * ind;
    end
    ContainerVolume(5) = inf;

    WaterVolume = WaterContentMap(RowPosition, ColumnPosition);
    WaterContentMap(RowPosition, ColumnPosition) = 0;
    
    
    WaterOutflowVolumes(:, 1) = SortedWaterLevels(:, 1);
    WaterOutflowVolumes(:, 2) = [0; 0; 0; 0; 0];
    if WaterVolume <=  ContainerVolume( 1 )
        WaterOutflowVolumes( 1, 2 ) = WaterVolume;
        WaterVolume = 0;
    elseif WaterVolume <=  (ContainerVolume( 1 ) + ContainerVolume( 2 )) && WaterVolume ~= 0
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + (WaterVolume - ContainerVolume( 1 )) / 2;
        WaterOutflowVolumes( 2, 2 ) = (WaterVolume - ContainerVolume( 1 )) / 2;
        WaterVolume = 0;
    elseif WaterVolume <= (ContainerVolume( 1 ) + ContainerVolume( 2 ) + ContainerVolume( 3 )) && WaterVolume ~= 0
        WaterOutflowToThirdArea = (WaterVolume - (ContainerVolume( 1 ) + ContainerVolume( 2 ))) / 3;
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + WaterOutflowToThirdArea;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + WaterOutflowToThirdArea;
        WaterOutflowVolumes( 3, 2 ) = WaterOutflowToThirdArea;
        WaterVolume = 0;
    elseif WaterVolume <=  (ContainerVolume( 1 ) + ContainerVolume( 2 ) + ContainerVolume( 3 ) + ContainerVolume( 4 )) && WaterVolume ~= 0
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + (WaterVolume - sum(ContainerVolume( 1 : 3 ))) / 4;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + (WaterVolume - sum(ContainerVolume( 1 : 3 ))) / 4;
        WaterOutflowVolumes( 3, 2 ) = ContainerVolume( 3 ) / 3 + (WaterVolume - sum(ContainerVolume( 1 : 3 ))) / 4;
        WaterOutflowVolumes( 4, 2 ) = (WaterVolume - sum(ContainerVolume( 1 : 3 ))) / 4;
        WaterVolume = 0;
    elseif WaterVolume <=  (ContainerVolume( 1 ) + ContainerVolume( 2 ) + ContainerVolume( 3 ) + ContainerVolume( 4 ) + ContainerVolume( 5 )) && WaterVolume ~= 0
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + ContainerVolume( 4 ) / 4 + (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + ContainerVolume( 4 ) / 4 + (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterOutflowVolumes( 3, 2 ) = ContainerVolume( 3 ) / 3 + ContainerVolume( 4 ) / 4 + (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterOutflowVolumes( 4, 2 ) = ContainerVolume( 4 ) / 4 + (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterOutflowVolumes( 5, 2 ) = (WaterVolume - sum(ContainerVolume( 1 : 4 ))) / 5;
        WaterVolume = 0;
    end

    [~, order] = sort(WaterOutflowVolumes(:, 1));
    WaterOutflowVolumes = WaterOutflowVolumes(order, :);
    
end

function [ WaterLevelMap ] = UpdateWaterLevelMap( WaterLevelMap, WaterContentMap, BottomHeightMap, RowPosition, ColumnPosition, AreaSize )
    WaterLevelMap(RowPosition - 1, ColumnPosition) = WaterContentMap(RowPosition - 1, ColumnPosition)/AreaSize + BottomHeightMap(RowPosition - 1, ColumnPosition);
    WaterLevelMap(RowPosition, ColumnPosition - 1) = WaterContentMap(RowPosition, ColumnPosition - 1)/AreaSize + BottomHeightMap(RowPosition, ColumnPosition - 1);
    WaterLevelMap(RowPosition, ColumnPosition + 1) = WaterContentMap(RowPosition, ColumnPosition + 1)/AreaSize + BottomHeightMap(RowPosition, ColumnPosition + 1);
    WaterLevelMap(RowPosition + 1, ColumnPosition) = WaterContentMap(RowPosition + 1, ColumnPosition)/AreaSize + BottomHeightMap(RowPosition + 1, ColumnPosition);
    WaterLevelMap(RowPosition, ColumnPosition) = WaterContentMap(RowPosition, ColumnPosition)/AreaSize + BottomHeightMap(RowPosition, ColumnPosition);
end