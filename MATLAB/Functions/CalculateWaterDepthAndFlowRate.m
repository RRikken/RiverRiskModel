function [ WaterLevelMap, WaterContents3dMap ] = CalculateWaterDepthAndFlowRate(AreaSize, WaterContentMap, WaterLevelMap, DikeBreachLocations, RiverWaterHeight, BreachFlowObject, BottomHeightMap)

TotalTimeSteps = length(RiverWaterHeight);
[ Rows, Columns ] = size(WaterContentMap);

for TimeStep = 1 : TotalTimeSteps
    
    MapRowMeasure = BreachFlowObject.InsideWaterHeightMeasuringLocation(1);
    MapColumnMeasure = BreachFlowObject.InsideWaterHeightMeasuringLocation(2);
    
    BreachFlowObject.WaterLevelRiver = RiverWaterHeight(TimeStep);
    BreachFlowObject.WaterLevelDikeRingArea = BottomHeightMap(MapRowMeasure,MapColumnMeasure);
    BreachFlow = BreachFlowObject.CalculateFlowThroughBreach;
    
    % Limit the BreachFlow to 1/3 of the water going through the river
    if BreachFlow > 4000
        BreachFlow = 4000;
    end
    
   for ind = 1 : length(DikeBreachLocations(:,1))
        % Add water from calculated breachflow to the dike failure postition
        Row = DikeBreachLocations(ind, 1);
        Column = DikeBreachLocations(ind, 2);
        WaterContentMap(Row, Column) = WaterContentMap(Row, Column) + BreachFlow / 3;
        WaterLevelMap(Row, Column) = BottomHeightMap(Row, Column) + WaterContentMap(Row, Column)/AreaSize;
   end
   parfor Column = 1 : Columns/2
       LeftTopCellColumnNr = Column * 2 - 1;
       for Row = 1 : Rows/2
           LeftTopCellRowNr = Row * 2 - 1;
           if % Not in water cell list
               break;
           else
                
           end
       end
   end
end
end