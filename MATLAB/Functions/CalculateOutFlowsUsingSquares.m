function [ WaterContentMap ] = CalculateOutFlowsUsingSquares( WaterContentMap, BottomHeightMap, AreaSize, RowPosition, ColumnPosition )

SquareBottomHeights = zeros(4,2);
SquareBottomHeights( : , 1 ) = [1; 2; 3; 4];
SquareBottomHeights( 1, 2 ) = BottomHeightMap(RowPosition,  ColumnPosition);
SquareBottomHeights( 2, 2 ) = BottomHeightMap(RowPosition,  ColumnPosition + 1);
SquareBottomHeights( 3, 2 ) = BottomHeightMap(RowPosition + 1,  ColumnPosition);
SquareBottomHeights( 4, 2 ) = BottomHeightMap(RowPosition + 1,  ColumnPosition + 1);

WaterVolume = WaterContentMap(RowPosition,  ColumnPosition) + WaterContentMap(RowPosition,  ColumnPosition + 1)...
    + WaterContentMap(RowPosition + 1,  ColumnPosition) + WaterContentMap(RowPosition + 1,  ColumnPosition + 1);

WaterContentMap(RowPosition,  ColumnPosition) = 0;
WaterContentMap(RowPosition,  ColumnPosition + 1) = 0;
WaterContentMap(RowPosition + 1,  ColumnPosition) = 0;
WaterContentMap(RowPosition + 1,  ColumnPosition + 1) = 0;

[~, order] = sort(SquareBottomHeights(:, 2));
SurroundingWaterlevels = SquareBottomHeights(order, :);

[WaterOutflowVolumes, WaterContentMap ] = DetermineOutflows(SurroundingWaterlevels, WaterContentMap, AreaSize, RowPosition, ColumnPosition);
[ WaterContentMap ] = PutOutflowIntoArea(  WaterContentMap, RowPosition, TotalRows, ColumnPosition, TotalColumns, WaterOutflowVolumes );

end