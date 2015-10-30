NumberOfContainers = 4;
SortedWaterLevels = [2 5.13200000000000;1 5.65500000000000;3 5.66900000000000;5 7.43600000000000;4 NaN];
WaterVolume = 4000;
ContainerVolume = [5230.00000000001;280.000000000005;53010.0000000000;Inf;0];

[ WaterOutflowVolumes ] = DivideWaterVolumeToContainers( NumberOfContainers, SortedWaterLevels, WaterVolume, ContainerVolume);