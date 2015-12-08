for ind = 1:100
WaterContentMapGPU = gpuArray(WaterContents3dMap(:,:,ind));
ReducedArrayGPU = ReduceArrayBySquareSumGPU( WaterContentMapGPU );

WaterContentMap = WaterContents3dMap(:,:,ind);
ReducedArray = ReduceArrayBySquareSum( WaterContentMap );
end
