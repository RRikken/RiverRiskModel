function [ WaterContentSquare ] = CalculateWaterFlowOverArea( WaterContentSquare, BottomHeightSquare, AreaSize )

BottomHeightsList = zeros(4,2);
BottomHeightsList( : , 1 ) = [1; 2; 3; 4];
BottomHeightsList( 1,2 ) = BottomHeightSquare( 1,1 );
BottomHeightsList( 2,2 ) = BottomHeightSquare( 1,2 );
BottomHeightsList( 3,2 ) = BottomHeightSquare( 2,1 );
BottomHeightsList( 4,2 ) = BottomHeightSquare( 2,2 );

[~, order] = sort(BottomHeightsList(:, 2));
SortedBottomLevels = BottomHeightsList(order, :);

WaterVolume = WaterContentSquare(1,1) + WaterContentSquare(1,2) + WaterContentSquare(2,1) + WaterContentSquare(2,2);

[ WaterOutflowVolumes ] = DetermineOutflows( SortedBottomLevels, WaterVolume, AreaSize );

WaterContentSquare = [ WaterOutflowVolumes( 1,2 ) WaterOutflowVolumes( 2,2 ); WaterOutflowVolumes( 3,2 ) WaterOutflowVolumes( 4,2 )];
end