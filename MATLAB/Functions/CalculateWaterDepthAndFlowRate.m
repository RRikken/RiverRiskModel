function [ WaterLevelMap, WaterContents3dMap ] = CalculateWaterDepthAndFlowRate(AreaSize, WaterContentMap, WaterLevelMap, FloodedCellsMap, DikeBreachLocations, RiverWaterHeight, BreachFlowObject, BottomHeightMap)

TotalTimeSteps = length(RiverWaterHeight);
[ Rows, Columns ] = size(WaterContentMap);
WaterContents3dMap = zeros(Rows, Columns, TotalTimeSteps/100);
BreachFlowTotal = 0;
FloodedCellsValues = values(FloodedCellsMap);
for CellInd = 1 : FloodedCellsMap.Count
    BottomHeightMap(FloodedCellsValues{CellInd}(1) + 1, FloodedCellsValues{CellInd}(2)) = 14;
end

for ind5 = 1 : TotalTimeSteps/100
    WaterContents3dMap(:,:,ind5) = WaterContentMap;
end

for TimeStep = 1 : TotalTimeSteps
    FloodedCellsValues = values(FloodedCellsMap);
    
    MapRowMeasure = BreachFlowObject.InsideWaterHeightMeasuringLocation(1);
    MapColumnMeasure = BreachFlowObject.InsideWaterHeightMeasuringLocation(2);
    
    BreachFlowObject.WaterLevelRiver = RiverWaterHeight(TimeStep);
    BreachFlowObject.WaterLevelDikeRingArea = BottomHeightMap(MapRowMeasure,MapColumnMeasure);
    BreachFlow = BreachFlowObject.CalculateFlowThroughBreach;
    BreachFlow = BreachFlow * 4;
    
    for ind = 1 : length(DikeBreachLocations(:,1))
        % Add water from calculated breachflow to the dike failure postition
        Row = DikeBreachLocations(ind, 1);
        Column = DikeBreachLocations(ind, 2);
        WaterContentMap(Row, Column) = WaterContentMap(Row, Column) + BreachFlow / 3;
        WaterLevelMap(Row, Column) = BottomHeightMap(Row, Column) + WaterContentMap(Row, Column)/AreaSize;
    end
    
    for ind2 = 1 : length(FloodedCellsValues(1,:))
         [ FloodedCellsMap, WaterLevelMap, WaterContentMap ] = ...
             CalculateOutFlows(  WaterLevelMap, WaterContentMap, FloodedCellsValues{ ind2 }(1), FloodedCellsValues{ ind2 }(2), FloodedCellsMap, AreaSize, BottomHeightMap );
    end
    
    LevelWaterTotal  = sum(sum(WaterLevelMap - BottomHeightMap, 'omitnan'),'omitnan') * AreaSize;
    WaterContentMapTotal = sum(sum(WaterContentMap, 'omitnan'), 'omitnan');
    if WaterContentMapTotal + 1 < LevelWaterTotal || WaterContentMapTotal - 1 >  LevelWaterTotal
        error('These numbers dont add up!')
    end
    
    BreachFlowTotal = BreachFlowTotal + BreachFlow;
    TotalWaterContents = sum(sum(WaterContentMap, 'omitnan'), 'omitnan');

    if TotalWaterContents + 1 < BreachFlowTotal || TotalWaterContents - 1 >  BreachFlowTotal
        error('These numbers dont add up!')
    end
    if mod(TimeStep, 100) == 0
        WaterContents3dMap(:,:, TimeStep/100) = WaterContentMap;
    end
end
end