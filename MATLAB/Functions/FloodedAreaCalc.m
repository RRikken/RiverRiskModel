function [ WaterContainerMap, WaterHeightMap ] = FloodedAreaCalc( DikeBreachLocations, UniqueIDs, BreachFlow, ahn100_gem, AreaSize )
%FLOODAREACALCULATION Summary of this function goes here
%   Detailed explanation goes here

[ WaterContainerMap ] = WaterContainer(  ahn100_gem, AreaSize );

UpdateList =  [DikeBreachLocations UniqueIDs];
[Rows, Columns ] = size(ahn100_gem);
WaterHeightMap = zeros(Rows, Columns, length(BreachFlow)/10);

for TimeStep = 1 : length(BreachFlow)
    for Ind = 1 : length(DikeBreachLocations)
        InflowIntoSingleCell = BreachFlow(TimeStep)/length(DikeBreachLocations(:,1));
        WaterContainerMap(DikeBreachLocations(Ind,1),DikeBreachLocations(Ind,2)).AddToWaterContents( 'FromBelow', InflowIntoSingleCell);
    end
    
    % First calculate all the outflows
    [RowsUpdateList, ~ ] = size(UpdateList);
    for RowNr = 1 : RowsUpdateList
        [ NewListItems, WaterOutflowVolumes ] = WaterContainerMap(UpdateList(RowNr,1),UpdateList(RowNr,2)).CalculateOutFlows(UpdateList);
        WaterContainerMap(UpdateList(RowNr,1),UpdateList(RowNr,2)).OutFlow = WaterOutflowVolumes;
        WaterContainerMap(UpdateList(RowNr,1),UpdateList(RowNr,2)).InFlow = [0; 0; 0; 0;];
        UpdateList = [ UpdateList;  NewListItems ];
    end
    
    % Second, put the outflows in the correct object
    [RowsUpdateList, ~ ] = size(UpdateList);
    for RowNr = 1 : RowsUpdateList
        WaterContainerMap(UpdateList(RowNr,1),UpdateList(RowNr,2)).OutflowToOtherContainersAndRetention();
    end
%     if mod(TimeStep, 10) == 0
%         WaterHeightMap(:,:,TimeStep/10) = MakeWaterHeightMap( WaterContainerMap );
%     end
end

end