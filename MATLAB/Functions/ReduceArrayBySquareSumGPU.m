function [ WaterContentsMapReduced ] = ReduceArrayBySquareSumGPU( WaterContentsMap )
%ReduceArrayBySquareSum Reduces an array by summing 2 by 2 squares

WaterContentsMapLeftTop = WaterContentsMap( 1:2:end - 1, 1:2:end - 1 );
WaterContentsMapRightTop = WaterContentsMap( 1:2:end - 1, 2:2:end );
WaterContentsMapLeftBottom = WaterContentsMap( 2:2:end, 1:2:end - 1 );
WaterContentsMapRightBottom = WaterContentsMap( 2:2:end, 2:2:end );

WaterContentsMapReduced = WaterContentsMapLeftTop + WaterContentsMapRightTop + WaterContentsMapLeftBottom + WaterContentsMapRightBottom;

end