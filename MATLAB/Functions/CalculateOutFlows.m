function [ WaterOutflowVolumes, NewListItems ] = CalculateOutFlows( StructureMap, WaterContentMap, RowPosition, ColumnPosition, UpdateList )

SurroundingCells = zeros(4,2);
SurroundingCells(1:4,1) = RowPosition;
SurroundingCells(1:4,2) = ColumnPosition;
SurroundingCells = SurroundingCells + [ -1 0; 0 -1; 0 1; 1 0; ];

for ind = 1 : 4
    WaterContents(ind) =  WaterContentMap(SurroundingCells(ind,1), SurroundingCells(ind,2));
end
    
Waterlevels = CheckSurroundingWaterLevels(StructureMap, RowPosition, ColumnPosition);
[ RowValuesSortedArray ] = SortWaterLevels( Waterlevels, StructureMap(RowPosition, ColumnPosition).InFlow );
WaterOutflowVolumes = DetermineOutflows(RowValuesSortedArray, StructureMap, WaterContentMap, RowPosition, ColumnPosition);
NewListItems = CheckUpdateList_mex(UpdateList, WaterOutflowVolumes, WaterContents, SurroundingCells);

end

function SurroundingWaterLevels = CheckSurroundingWaterLevels(WaterLevelMap, RowPosition, ColumnPosition)
SurroundingWaterLevels = [1 NaN; 2 NaN; 3 NaN; 4 NaN; 5 NaN];
[ MaxRows, MaxColumns ] = size(WaterLevelMap);
WaterLevel = WaterLevelMap(RowPosition, ColumnPosition).WaterLevel(1,1);
SurroundingWaterLevels(5,2) = WaterLevel;
if RowPosition - 1 >= 1
    SurroundingWaterLevels(1,2) = WaterLevelMap(RowPosition - 1, ColumnPosition).WaterLevel(1,1);
end
if ColumnPosition - 1 >= 1
    SurroundingWaterLevels(2,2) = WaterLevelMap(RowPosition, ColumnPosition - 1).WaterLevel(1,1);
end
if ColumnPosition + 1 <= MaxColumns
    SurroundingWaterLevels(3,2) = WaterLevelMap(RowPosition, ColumnPosition + 1).WaterLevel(1,1);
end
if RowPosition + 1 <= MaxRows
    SurroundingWaterLevels(4,2) = WaterLevelMap(RowPosition + 1, ColumnPosition).WaterLevel(1,1);
end
end

function [ SortedWaterLevels, AllWaterLevels ]  = SortWaterLevels( SurroundingWaterLevels, Inflow )
AllWaterLevels = SurroundingWaterLevels;
InflowLogical = zeros(5,2);
InflowLogical(1:4,2) = Inflow(:,2) > 0;
SurroundingWaterLevels( InflowLogical == 1 ) = NaN;

SortedWaterLevels = SurroundingWaterLevels;

[~, order] = sort(SortedWaterLevels(:, 2));
SortedWaterLevels = SortedWaterLevels(order, :);
end

function [ WaterOutflowVolumes ] = DetermineOutflows( SortedWaterLevels, StructureMap, WaterContentMap, RowPosition, ColumnPosition )


if StructureMap(RowPosition, ColumnPosition).WaterLevel(1,1) > SortedWaterLevels(1,2)
    
    NumberOfContainers = 5 - sum(isnan(SortedWaterLevels(:, 2)));
    
    if SortedWaterLevels(1,2) < StructureMap(RowPosition, ColumnPosition).BottomHeight(1,1);
        % This is waterheight because the bottom is higher then the lowest waterheight
        % in the other containers
        WaterVolume = WaterContentMap(RowPosition, ColumnPosition);
        SortedWaterLevels = ReSortWithBottomHeight(SortedWaterLevels, StructureMap(RowPosition, ColumnPosition).BottomHeight(1,1));
    else
        if StructureMap(RowPosition, ColumnPosition).WaterLevel(1,1) < SortedWaterLevels(1,2)
            error('Waterlevel too low')
        end
        % This is the waterlevel because bottomheight + waterheight = level
        DifferenceInWaterLevel = StructureMap(RowPosition, ColumnPosition).WaterLevel(1,1) - SortedWaterLevels(1,2);
        WaterVolume = DifferenceInWaterLevel * StructureMap(RowPosition, ColumnPosition).AreaSize(1,1);
    end
    
    ContainerVolume = zeros(5,1);
    
    for ind = 1 : NumberOfContainers
        if ind + 1 > NumberOfContainers
            ContainerVolume(ind,1) = Inf;
        else
            ContainerVolume(ind,1) = (SortedWaterLevels(ind + 1, 2) - SortedWaterLevels(ind, 2) ) * StructureMap(RowPosition, ColumnPosition).AreaSize(1,1) * ind;
        end
    end
    
    WaterOutflowVolumes = DivideWaterVolumeToContainers_mex( NumberOfContainers, SortedWaterLevels, WaterVolume, ContainerVolume );
    if any(WaterOutflowVolumes(:,2) < -0.00000001 )
        error('Outflow cannot be negative')
    end
else
    WaterOutflowVolumes = [1 0; 2 0; 3 0; 4 0; 5 0];
end
[~, order] = sort(WaterOutflowVolumes(:, 1));
WaterOutflowVolumes = WaterOutflowVolumes(order, :);
end

function SortedWaterLevels = ReSortWithBottomHeight(SortedWaterLevels, SelfBottomHeight)
[~, order] = sort(SortedWaterLevels(:, 1));
SortedWaterLevels = SortedWaterLevels(order, :);
SortedWaterLevels(5,2) = SelfBottomHeight;

[~, order] = sort(SortedWaterLevels(:, 2));
SortedWaterLevels = SortedWaterLevels(order, :);
end