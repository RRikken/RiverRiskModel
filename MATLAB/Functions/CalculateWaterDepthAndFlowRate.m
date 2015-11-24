function [ WaterLevelMap, WaterContents3dMap ] = CalculateWaterDepthAndFlowRate(AreaSize, WaterContentMap, WaterLevelMap, FloodedCellsMap, DikeBreachLocations, RiverWaterHeight, BreachFlowObject, BottomHeightMap)

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
    
    if isreal(BreachFlow) == 0
        error('Real BreachFlows only!')
    end
    
    for ind = 1 : length(DikeBreachLocations(:,1))
        % Add water from calculated breachflow to the dike failure postition
        Row = DikeBreachLocations(ind, 1);
        Column = DikeBreachLocations(ind, 2);
        WaterContentMap(Row, Column) = WaterContentMap(Row, Column) + BreachFlow / 3;
        WaterLevelMap(Row, Column) = BottomHeightMap(Row, Column) + WaterContentMap(Row, Column)/AreaSize;
    end
    
    WaterOutflowVolumes = cell(1,length(FloodedCellsValues(1,:)));
    for ind2 = 1 : length(FloodedCellsValues(1,:))
         [ WaterOutflowVolumes{ ind2 }, FloodedCellsMap, WaterLevelMap, WaterContentMap ] = ...
             CalculateOutFlows(  WaterLevelMap, WaterContentMap, FloodedCellsValues{ ind2 }(1), FloodedCellsValues{ ind2 }(2), FloodedCellsMap, AreaSize, BottomHeightMap );
    end
    LevelWaterTotal  = sum(sum(WaterLevelMap - BottomHeightMap, 'omitnan'),'omitnan') * AreaSize;
    WaterContentMapTotal = sum(sum(WaterContentMap, 'omitnan'), 'omitnan');
    if WaterContentMapTotal + 1 < LevelWaterTotal || WaterContentMapTotal - 1 >  LevelWaterTotal
        error('These numbers dont add up!')
    end
    
    for  ind3 = 1 : length(FloodedCellsValues(1,:))
        [ WaterContentMap, WaterLevelMap ] = PutOutflowIntoArea(  WaterContentMap, WaterLevelMap, FloodedCellsValues{ ind3 }(1), FloodedCellsValues{ ind3 }(2), WaterOutflowVolumes{ind3}, AreaSize );
        WaterLevelMap(FloodedCellsValues{ ind3 }(1), FloodedCellsValues{ ind3 }(2)) =...
            BottomHeightMap(FloodedCellsValues{ ind3 }(1), FloodedCellsValues{ ind3 }(2)) + WaterContentMap(FloodedCellsValues{ ind3 }(1), FloodedCellsValues{ ind3 }(2))/AreaSize;
    end
    clear WaterOutflowVolumes
    
    LevelWaterTotal  = sum(sum(WaterLevelMap - BottomHeightMap, 'omitnan'),'omitnan') * AreaSize;
    WaterContentMapTotal = sum(sum(WaterContentMap, 'omitnan'), 'omitnan');
    if WaterContentMapTotal + 1 < LevelWaterTotal || WaterContentMapTotal - 1 >  LevelWaterTotal
        error('These numbers dont add up!')
    end
    
    BreachFlowTotal = BreachFlowTotal + BreachFlow;
    TotalWaterContents = sum(sum(WaterContentMap, 'omitnan'), 'omitnan');

%     if TotalWaterContents + 1 < BreachFlowTotal || TotalWaterContents - 1 >  BreachFlowTotal
%         error('These numbers dont add up!')
%     end
        WaterContents3dMap(:,:, TimeStep) = WaterContentMap;
end
end