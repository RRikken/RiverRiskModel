function [ WaterOutflowVolumes, NewListItems ] = CalculateOutFlows( StructureMap, WaterContentMap, RowPosition, ColumnPosition, UpdateList )

Waterlevels = CheckSurroundingWaterLevels(StructureMap, RowPosition, ColumnPosition);
[ RowValuesSortedArray, ~ ] = SortWaterLevels( Waterlevels, StructureMap(RowPosition, ColumnPosition).InFlow );
WaterOutflowVolumes = DetermineOutflows(RowValuesSortedArray, StructureMap, WaterContentMap, RowPosition, ColumnPosition);
NewListItems = CheckUpdateList(UpdateList, WaterOutflowVolumes, RowPosition, ColumnPosition);

end

function SurroundingWaterLevels = CheckSurroundingWaterLevels(WaterLevelMap, RowPosition, ColumnPosition)
SurroundingWaterLevels = [1 NaN; 2 NaN; 3 NaN; 4 NaN; 5 NaN];
[ MaxRows, MaxColumns ] = size(WaterLevelMap);
SurroundingWaterLevels(5,2) = WaterLevelMap(RowPosition, ColumnPosition).WaterLevel;
if RowPosition - 1 >= 1
    SurroundingWaterLevels(1,2) = WaterLevelMap(RowPosition - 1, ColumnPosition).WaterLevel;
end
if ColumnPosition - 1 >= 1
    SurroundingWaterLevels(2,2) = WaterLevelMap(RowPosition, ColumnPosition - 1).WaterLevel;
end
if ColumnPosition + 1 <= MaxColumns
    SurroundingWaterLevels(3,2) = WaterLevelMap(RowPosition, ColumnPosition + 1).WaterLevel;
end
if RowPosition + 1 <= MaxRows
    SurroundingWaterLevels(4,2) = WaterLevelMap(RowPosition + 1, ColumnPosition).WaterLevel;
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


if StructureMap(RowPosition, ColumnPosition).WaterLevel > SortedWaterLevels(1,2)
    
    NumberOfContainers = 5 - sum(isnan(SortedWaterLevels(:, 2)));
    
    if SortedWaterLevels(1,2) < StructureMap(RowPosition, ColumnPosition).BottomHeight;
        % This is waterheight because the bottom is higher then the lowest waterheight
        % in the other containers
        WaterVolume = WaterContentMap(RowPosition, ColumnPosition);
        SortedWaterLevels = ReSortWithBottomHeight(SortedWaterLevels, StructureMap(RowPosition, ColumnPosition).BottomHeight);
    else
        if StructureMap(RowPosition, ColumnPosition).WaterLevel < SortedWaterLevels(1,2)
            error('Waterlevel too low')
        end
        % This is the waterlevel because bottomheight + waterheight = level
        DifferenceInWaterLevel = StructureMap(RowPosition, ColumnPosition).WaterLevel - SortedWaterLevels(1,2);
        WaterVolume = DifferenceInWaterLevel * StructureMap(RowPosition, ColumnPosition).AreaSize;
    end
    
    ContainerVolume = zeros(5,1);
    
    for ind = 1 : NumberOfContainers
        if ind + 1 > NumberOfContainers
            ContainerVolume(ind,1) = Inf;
        else
            ContainerVolume(ind,1) = (SortedWaterLevels(ind + 1, 2) - SortedWaterLevels(ind, 2) ) * StructureMap(RowPosition, ColumnPosition).AreaSize * ind;
        end
    end
    
    WaterOutflowVolumes = DivideWaterVolumeToContainers( NumberOfContainers, SortedWaterLevels, WaterVolume, ContainerVolume );
    
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


function WaterOutflowVolumes = DivideWaterVolumeToContainers( NumberOfContainers, SortedWaterLevels, WaterVolume, ContainerVolume)
WaterOutflowVolumes = zeros(5,2);
WaterOutflowVolumes(:, 1) = SortedWaterLevels(:, 1);
WaterOutflowVolumes(:, 2) = [0; 0; 0; 0; 0];

for ind = 1 : NumberOfContainers
    if sum( ContainerVolume( 1 : ind) ) > WaterVolume
        WaterOutflowVolumes(1 : ind - 1, 2) = ContainerVolume(1 : ind - 1, 1);
        if ind > 1
            WaterOutflowVolumes(ind, 2) =WaterVolume - sum(ContainerVolume(1 : ind - 1, 1));
        elseif ind == 1
            WaterOutflowVolumes(ind, 2) =WaterVolume;
        end
    end
    if WaterOutflowVolumes(ind, 2) < -0.0000001
%         error('Outflow cannot be negative')
    end
    if sum(WaterOutflowVolumes(:,2)) > WaterVolume - 0.00001 && sum(WaterOutflowVolumes(:,2)) < WaterVolume + 0.00001
        break;
    elseif sum(WaterOutflowVolumes(:,2)) > WaterVolume
%         error('Wateroutflow exceeds water available.')
    end
end

end

function NewObjectsList = CheckUpdateList(UpdateList, WaterOutflowVolumes, RowPosition, ColumnPosition)
NewObjectsList = [];
for ind = 1 : 4
    SelectedCell = [ NaN NaN ];
    if ind == 1 && WaterOutflowVolumes(1, 2) > 0
        SelectedCell = [ RowPosition - 1, ColumnPosition ];
    elseif ind == 2 && WaterOutflowVolumes(2, 2) > 0
        SelectedCell = [ RowPosition, ColumnPosition - 1 ];
    elseif ind == 3 && WaterOutflowVolumes(3, 2) > 0
        SelectedCell = [ RowPosition, ColumnPosition + 1];
    elseif ind == 4 && WaterOutflowVolumes(4, 2) > 0
        SelectedCell = [ RowPosition + 1, ColumnPosition ];
    end
    
    n=floor(log10(SelectedCell(2)));
    UniqueID = 10^(n+1)*SelectedCell(1) + SelectedCell(2);
    
    UniqueIDsUpdateList = UpdateList(:,3);
    IsIDInUpdateList = NaN;
    if isempty(UniqueID) == 0
        ListLogical = UniqueIDsUpdateList == UniqueID;
        IsIDInUpdateList = any(ListLogical);
    end
    if IsIDInUpdateList == 0 && any(isnan(SelectedCell)) == 0
        SelectedCell = [ SelectedCell UniqueID];
        NewObjectsList = [ NewObjectsList; SelectedCell];
    end
end
end