function [ WaterContentsMapReduced ] = ReduceArrayBySquareSum( WaterContentsMap, Start )
%ReduceArrayBySquareSum Reduces an array by summing 2 by 2 squares
if strcmp( Start, 'StartAt_1,1' )
    WaterContentsMapLeftTop = WaterContentsMap( 1:2:end - 1, 1:2:end - 1 );
    WaterContentsMapRightTop = WaterContentsMap( 1:2:end - 1, 2:2:end );
    WaterContentsMapLeftBottom = WaterContentsMap( 2:2:end, 1:2:end - 1 );
    WaterContentsMapRightBottom = WaterContentsMap( 2:2:end, 2:2:end );
elseif strcmp( Start, 'StartAt_2,2' )
    WaterContentsMapLeftTop = WaterContentsMap( 2:2:end - 1, 2:2:end - 1 );
    WaterContentsMapRightTop = WaterContentsMap( 2:2:end - 1, 3:2:end );
    WaterContentsMapLeftBottom = WaterContentsMap( 3:2:end, 2:2:end - 1 );
    WaterContentsMapRightBottom = WaterContentsMap( 3:2:end, 3:2:end );
end
WaterContentsMapReduced = WaterContentsMapLeftTop + WaterContentsMapRightTop + WaterContentsMapLeftBottom + WaterContentsMapRightBottom;
end