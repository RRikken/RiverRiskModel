function [ FloodDepthMap, FlowRateMap, WaterContentsArraysForGraphs ] = CalculateWaterDepthAndFlowRate(AreaMapStructure, WaterContentMap, UpdateList, DikeBreachLocations, BreachInFlowLogicalRowNumber, BreachFlow)

WaterContentsArraysForGraphs = zeros(223, 983, length(BreachFlow)/2);


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
    TotalBreachFlow = sum(BreachFlow(1 : TimeStep)) * 3;
    if TotalWaterContents + 1 < TotalBreachFlow || TotalWaterContents - 1 >  TotalBreachFlow
        error('These numbers dont add up!')
    end
    if mod(TimeStep, 2) == 0
        WaterContentsArraysForGraphs(:,:, TimeStep/2) = WaterContentMap;
    end
    
end
FloodDepthMap = WaterContentMap;
FlowRateMap = NaN;
end