function [ WaterOutflowVolumes, FloodedCellsMap, WaterLevelMap ] = CalculateOutFlows( StructureMap, WaterLevelMap, WaterContentMap, RowPosition, ColumnPosition, FloodedCellsMap, AreaSize )

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

[ SurroundingWaterlevels, WaterLevelMap ] = CheckSurroundingWaterLevels(WaterLevelMap, RowPosition, TotalRows, ColumnPosition, TotalColumns, SurroundingWaterLevels);
[~, order] = sort(SurroundingWaterlevels(:, 2));
SurroundingWaterlevels = SurroundingWaterlevels(order, :);
WaterOutflowVolumes = DetermineOutflows(SurroundingWaterlevels, WaterLevelMap, AreaSize, RowPosition, ColumnPosition);

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

function [ SurroundingWaterLevels, WaterLevelMap ] = CheckSurroundingWaterLevels(WaterLevelMap, RowPosition, TotalRows, ColumnPosition, TotalColumns, SurroundingWaterLevels)

SurroundingWaterLevels(5,2) = WaterLevelMap(RowPosition, ColumnPosition);

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

function [ WaterOutflowVolumes ] = DetermineOutflows( SortedWaterLevels, WaterLevelMap, AreaSize, RowPosition, ColumnPosition )


if WaterLevelMap(RowPosition, ColumnPosition) > SortedWaterLevels(1,2)
    
    if WaterLevelMap(RowPosition, ColumnPosition) < SortedWaterLevels(1,2)
        error('Waterlevel too low')
    end
    
    DifferenceInWaterLevel = WaterLevelMap(RowPosition, ColumnPosition).WaterLevel(1,1) - SortedWaterLevels(1,2);
    WaterVolume = DifferenceInWaterLevel * AreaSize;

    ContainerVolume = zeros(5,1);
    
    for ind = 1 : NumberOfContainers
        if ind + 1 > NumberOfContainers
            ContainerVolume(ind,1) = Inf;
        else
            ContainerVolume(ind,1) = (SortedWaterLevels(ind + 1, 2) - SortedWaterLevels(ind, 2) ) * AreaSize * ind;
        end
    end
    
    WaterOutflowVolumes = DivideWaterVolumeToContainers( NumberOfContainers, SortedWaterLevels, WaterVolume, ContainerVolume );
    if any(WaterOutflowVolumes(:,2) < -0.00000001 )
        error('Outflow cannot be negative')
    end
    [~, order] = sort(WaterOutflowVolumes(:, 1));
    WaterOutflowVolumes = WaterOutflowVolumes(order, :);
else
    WaterOutflowVolumes = [1 0; 2 0; 3 0; 4 0; 5 0];
end
end