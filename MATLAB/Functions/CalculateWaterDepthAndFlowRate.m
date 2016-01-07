function [ WaterContents3dMap ] = CalculateWaterDepthAndFlowRate(AreaSize, WaterContentMap, DikeBreachLocations, RiverWaterHeight, BreachFlowObject, BottomHeightMap)
%% Set values that stay the same for all loop iterations
[ AllRows, AllColumns ] = size(WaterContentMap);
Rows = fix( AllRows / 2 );
Columns = fix( AllColumns / 2 );
TotalTimeSteps = length(RiverWaterHeight);
WaterContents3dMap = zeros(AllRows, AllColumns, TotalTimeSteps / 10);

ReducedBottomHeightMap11 = cell(111, 491);
ReducedBottomHeightMap22 = cell(111, 491);
ReducedBottomHeightMap11 = SliceArrayForParForLoop( ReducedBottomHeightMap11, BottomHeightMap, 'ReduceHeightMap_StartAt_1,1');
ReducedBottomHeightMap22 = SliceArrayForParForLoop( ReducedBottomHeightMap22, BottomHeightMap, 'ReduceHeightMap_StartAt_2,2');

HeightMap11OnWorker = parallel.pool.Constant(ReducedBottomHeightMap11);
HeightMap22OnWorker = parallel.pool.Constant(ReducedBottomHeightMap22);

for TimeStep = 1 : TotalTimeSteps
    %% Loop over all the floodtime
    %Calculate breachflow for this iteration
    MapRowMeasure = BreachFlowObject.InsideWaterHeightMeasuringLocation(1);
    MapColumnMeasure = BreachFlowObject.InsideWaterHeightMeasuringLocation(2);
    
    BreachFlowObject.WaterLevelRiver = RiverWaterHeight(TimeStep);
    BreachFlowObject.WaterLevelDikeRingArea = BottomHeightMap(MapRowMeasure,MapColumnMeasure);
    BreachFlow = BreachFlowObject.CalculateFlowThroughBreach * 4;
    
    % Limit the BreachFlow to 1/3 of the water going through the river
    if BreachFlow > 4000 * 4
        BreachFlow = 4000 * 4;
    end
    
    for ind = 1 : length(DikeBreachLocations(:,1))
        % Add water from calculated breachflow to the dike failure postition
        Row = DikeBreachLocations(ind, 1);
        Column = DikeBreachLocations(ind, 2);
        WaterContentMap(Row, Column) = WaterContentMap(Row, Column) + BreachFlow / length(DikeBreachLocations(:,1));
    end
    
    %% First calculation: starts at [ 1,1 1,2 ; 2,1 2,2 ]
    [ WaterContentsMapReduced ] = ReduceArrayBySquareSum( WaterContentMap, 'StartAt_1,1' );
    [ WaterContentsMapSlicedForParForLoop ] = SliceArrayForParForLoop( WaterContentsMapReduced, WaterContentMap, 'StartAt_1,1');
    TempWaterContentArray = cell(Rows, Columns);
    
    parfor Row = 1 : Rows
        for Column = 1 : Columns 
            if WaterContentsMapReduced(Row, Column) > 0
                TempWaterContentArray{ Row, Column } = CalculateWaterFlowOverArea( WaterContentsMapSlicedForParForLoop{Row, Column}, HeightMap11OnWorker.Value{ Row, Column }, AreaSize );
            end
        end
    end

    for Row = 1 : Rows
        for Column = 1 : Columns
            if WaterContentsMapReduced( Row, Column ) > 0
                WaterContentMap(Row * 2 - 1 : Row * 2, Column * 2 - 1 : Column *2) = TempWaterContentArray{ Row, Column };
            end
        end
    end
    
    clear TempWaterContentArray WaterContentsMapReduced WaterContentsMapSlicedForParForLoop
    
    %% Second calculation: squares now shifted to [ 2,2 2,3; 3,2 3,3]
    [ WaterContentsMapReduced ] = ReduceArrayBySquareSum( WaterContentMap, 'StartAt_2,2' );
    [ WaterContentsMapSlicedForParForLoop ] = SliceArrayForParForLoop( WaterContentsMapReduced, WaterContentMap, 'StartAt_2,2');
    TempWaterContentArray = cell(Rows, Columns);
    
    parfor Row = 1 : Rows
        for Column = 1 : Columns
            if WaterContentsMapReduced( Row, Column ) > 0
                TempWaterContentArray{ Row, Column } = CalculateWaterFlowOverArea( WaterContentsMapSlicedForParForLoop{Row, Column}, HeightMap22OnWorker.Value{ Row, Column }, AreaSize );
            end
        end
    end
   
    for Row = 1 : Rows
        for Column = 1 : Columns
            if WaterContentsMapReduced( Row, Column ) > 0
                WaterContentMap(Row * 2 : Row * 2 + 1, Column * 2  : Column * 2 + 1) = TempWaterContentArray{ Row, Column };
            end
        end
    end
    
    clear TempWaterContentArray WaterContentsMapReduced WaterContentsMapSlicedForParForLoop
    %% Save the watercontentmap for this iteration
    if mod(TimeStep, 10) == 0
        WaterContents3dMap(:,:, TimeStep / 10) = WaterContentMap;
    end
end
end