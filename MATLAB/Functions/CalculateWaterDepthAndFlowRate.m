function [ FloodDepthMap, FlowRateMap, WaterLevelMap, WaterContentsArraysForGraphs ] = CalculateWaterDepthAndFlowRate(AreaMapStructure, WaterContentMap, UpdateList, DikeBreachLocations, BreachInFlowLogicalRowNumber, BreachFlow)
[ Rows, Columns ] = size(WaterContentMap);
% WaterContentsArraysForGraphs = zeros(Rows, Columns, length(BreachFlow)/2);
BreachFlow = BreachFlow ./ length(DikeBreachLocations(:,1));
FlowRateMap = zeros(Rows, Columns, length(BreachFlow));
WaterLevelMap = zeros(Rows, Columns, length(BreachFlow)/6);
for ind4 = 1 : length(BreachFlow)
    FlowRateMap(:,:,ind4) = WaterContentMap;
end
for ind5 = 1 : length(BreachFlow)/6
    WaterLevelMap(:,:,ind5) = WaterContentMap;
end

for TimeStep = 1 : length(BreachFlow) 
    NewUpdateListItems = [];
    for ind = 1 : length(DikeBreachLocations(:,1))
        Row = DikeBreachLocations(ind, 1);
        Column = DikeBreachLocations(ind, 2);
        WaterContentMap(Row, Column) = WaterContentMap(Row, Column) + BreachFlow(TimeStep);
        AreaMapStructure(Row, Column).WaterLevel = WaterContentMap(Row, Column) / AreaMapStructure(Row, Column).AreaSize + AreaMapStructure(Row, Column).BottomHeight;
        AreaMapStructure(Row, Column).WaterDepth = WaterContentMap(Row, Column) / AreaMapStructure(Row, Column).AreaSize;
        AreaMapStructure(Row, Column).InFlow(BreachInFlowLogicalRowNumber,2) = 1;
    end
    
    for ind2 = 1 : length(UpdateList(:,1))
        [ WaterOutflowVolumes, NewListItem ] = CalculateOutFlows(  AreaMapStructure, WaterContentMap, UpdateList( ind2, 1 ), UpdateList( ind2, 2 ), UpdateList );
        AreaMapStructure( UpdateList( ind2, 1 ), UpdateList( ind2, 2 ) ).OutFlow = WaterOutflowVolumes;
        
        FlowRateMap( UpdateList( ind2, 1 ), UpdateList( ind2, 2 ),  TimeStep) =  sum(WaterOutflowVolumes(:,2)) / ...
            (sqrt(AreaMapStructure(UpdateList( ind2, 1 ), UpdateList( ind2, 2 )).AreaSize) * AreaMapStructure(UpdateList( ind2, 1 ), UpdateList( ind2, 2 )).WaterLevel );
        NewUpdateListItems = [ NewUpdateListItems; NewListItem];
    end
    
    for  ind3 = 1 : length(UpdateList(:,1))
        [ AreaMapStructure, WaterContentMap ] = PutOutflowIntoArea( AreaMapStructure, WaterContentMap, UpdateList( ind3, 1 ), UpdateList( ind3, 2 ) );
        AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).WaterLevel = ...
            WaterContentMap(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )) / AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).AreaSize...
            + AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).BottomHeight;
        AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).WaterDepth =...
            WaterContentMap(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )) / AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).AreaSize;
    end
    
    UpdateList = [UpdateList; NewUpdateListItems];
    TotalWaterContents = sum(sum(WaterContentMap, 'omitnan'), 'omitnan');
    TotalBreachFlow = sum(BreachFlow(1 : TimeStep)) * length(DikeBreachLocations(:,1));
    if TotalWaterContents + 1 < TotalBreachFlow || TotalWaterContents - 1 >  TotalBreachFlow
        error('These numbers dont add up!')
    end
%     if mod(TimeStep, 2) == 0
%         WaterContentsArraysForGraphs(:,:, TimeStep/2) = WaterContentMap;
%     end
    
    if mod(TimeStep, 6) == 0
        [ Rows, Columns ] = size(WaterContentMap);
        for Row = 1 : Rows
            for Column = 1 : Columns
                WaterLevelMap(Row, Column, TimeStep/6) = AreaMapStructure(Row, Column).WaterDepth(1,1);
            end
        end
    end
end
FloodDepthMap = WaterContentMap;
WaterContentsArraysForGraphs = NaN;
end