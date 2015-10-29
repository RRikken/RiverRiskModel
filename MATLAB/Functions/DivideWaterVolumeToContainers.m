function WaterOutflowVolumes = DivideWaterVolumeToContainers( NumberOfContainers, SortedWaterLevels, WaterVolume, ContainerVolume)
WaterOutflowVolumes = zeros(5,2);
WaterOutflowVolumes(:, 1) = SortedWaterLevels(:, 1);
WaterOutflowVolumes(:, 2) = [0; 0; 0; 0; 0];
ind = 1;
while 1 > 0
    if sum( ContainerVolume( 1 : ind) ) >= WaterVolume
        WaterOutflowVolumes(1 : ind - 1, 2) = ContainerVolume(1 : ind - 1, 1);
        if ind > 1
            WaterOutflowVolumes(ind, 2) =WaterVolume - sum(ContainerVolume(1 : ind - 1, 1));
            if WaterOutflowVolumes(ind, 2) < 0
                error('Outflow cannot be negative')
            end
        elseif ind == 1
            WaterOutflowVolumes(ind, 2) =WaterVolume;
        end
        break;
    else
        if ind > NumberOfContainers
            error('Not enough watercontainers')
        end
    end
    ind = ind + 1;
end
end