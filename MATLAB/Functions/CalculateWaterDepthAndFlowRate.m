function [ WaterLevelMap, WaterContents3dMap ] = CalculateWaterDepthAndFlowRate(AreaSize, AreaMapStructure, WaterContentMap, WaterLevelMap, FloodedCellsMap, DikeBreachLocations, BreachInFlowLogicalRowNumber, RiverWaterHeight, BreachFlowObject)

TotalTimeSteps = length(RiverWaterHeight);
[ Rows, Columns ] = size(WaterContentMap);
WaterContents3dMap = zeros(Rows, Columns, TotalTimeSteps);
BreachFlowTotal = 0;

for ind5 = 1 : TotalTimeSteps
    WaterContents3dMap(:,:,ind5) = WaterContentMap;
end

for TimeStep = 1 : TotalTimeSteps
    FloodedCellsValues = values(FloodedCellsMap);
    
    MapRowMeasure = BreachFlowObject.InsideWaterHeightMeasuringLocation(1);
    MapColumnMeasure = BreachFlowObject.InsideWaterHeightMeasuringLocation(2);
    
    BreachFlowObject.WaterLevelRiver = RiverWaterHeight(TimeStep);
    BreachFlowObject.WaterLevelDikeRingArea = WaterLevelMap(MapRowMeasure,MapColumnMeasure);
    BreachFlow = BreachFlowObject.CalculateFlowThroughBreach;
    
    for ind = 1 : length(DikeBreachLocations(:,1))
        Row = DikeBreachLocations(ind, 1);
        Column = DikeBreachLocations(ind, 2);
        WaterContentMap(Row, Column) = WaterContentMap(Row, Column) + BreachFlow;
        WaterLevelMap(Row, Column) = AreaMapStructure(Row, Column).BottomHeight + WaterContentMap(Row, Column)/AreaSize;
        AreaMapStructure(Row, Column).InFlow(BreachInFlowLogicalRowNumber,2) = 1;
    end
    
    for ind2 = 1 : length(FloodedCellsValues(1,:))
        [ WaterOutflowVolumes, FloodedCellsMap ] = CalculateOutFlows(  AreaMapStructure, WaterLevelMap, WaterContentMap, FloodedCellsValues{ ind2 }(1), FloodedCellsValues{ ind2 }(2), FloodedCellsMap, AreaSize );
    end
    
    for  ind3 = 1 : length(FloodedCellsValues(1,:))
        [ WaterContentMap ] = PutOutflowIntoArea(  WaterContentMap, FloodedCellsValues{ ind3 }(1), FloodedCellsValues{ ind3 }(2), WaterOutflowVolumes );
        WaterLevelMap = AreaMapStructure(FloodedCellsValues{ ind3 }(1), FloodedCellsValues{ ind3 }(2)).BottomHeight + WaterContentMap(FloodedCellsValues{ ind3 }(1), FloodedCellsValues{ ind3 }(2))/AreaSize;
    end
    
    BreachFlowTotal = BreachFlowTotal + BreachFlow;
    TotalWaterContents = sum(sum(WaterContentMap, 'omitnan'), 'omitnan');
    TotalBreachFlow = BreachFlowTotal * length(DikeBreachLocations(:,1));
    if TotalWaterContents + 1 < TotalBreachFlow || TotalWaterContents - 1 >  TotalBreachFlow
        error('These numbers dont add up!')
    end
    
    WaterContents3dMap(:,:, TimeStep) = WaterContentMap;
end
end