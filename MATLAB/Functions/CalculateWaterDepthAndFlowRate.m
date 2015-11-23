function [ WaterLevelMap, WaterContents3dMap ] = CalculateWaterDepthAndFlowRate(AreaMapStructure, WaterContentMap, UpdateList, DikeBreachLocations, BreachInFlowLogicalRowNumber, RiverWaterHeight, WidthBreach, HeightBreach)

[ Rows, Columns ] = size(WaterContentMap);
WaterLevelMap = zeros(Rows, Columns, length(RiverWaterHeight));
WaterContents3dMap = WaterLevelMap;

for ind5 = 1 : length(RiverWaterHeight)
    WaterLevelMap(:,:,ind5) = WaterContentMap;
    WaterContents3dMap(:,:,ind5) = WaterContentMap;
end

for TimeStep = 1 : length(RiverWaterHeight)
    NewUpdateListItems = [];
    BreachFlow = CalculateFlowThroughBreach(WidthBreach, HeightBreach, RiverWaterHeight(TimeStep), WaterLevelDikeRingArea);
    
    for ind = 1 : length(DikeBreachLocations(:,1))
        Row = DikeBreachLocations(ind, 1);
        Column = DikeBreachLocations(ind, 2);
        WaterContentMap(Row, Column) = WaterContentMap(Row, Column) + BreachFlow;
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
    TotalBreachFlow = sum(BreachFlow(1 : TimeStep)) * length(DikeBreachLocations(:,1));
    if TotalWaterContents + 1 < TotalBreachFlow || TotalWaterContents - 1 >  TotalBreachFlow
        error('These numbers dont add up!')
    end
    
    WaterContents3dMap(:,:, TimeStep) = WaterContentMap;
    [ Rows, Columns, Pages ] = size(WaterLevelMap);
    for Column = 1 : Columns
        for Row = 1 : Rows
            WaterLevelMap(Row, Column, TimeStep) = AreaMapStructure(Row, Column).WaterDepth(1,1);
        end
    end
end
end