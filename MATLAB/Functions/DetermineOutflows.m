function [ WaterOutflowVolumes, WaterContentMap ] = DetermineOutflows( SortedWaterLevels, WaterContentMap, AreaSize, RowPosition, ColumnPosition )
     
        ContainerVolumeCache = zeros(1,5);
    
        WaterOutflowVolumesCache = zeros(5,2);
    
    
    WaterOutflowVolumes = WaterOutflowVolumesCache;
    ContainerVolume = ContainerVolumeCache;
    
    for ind = 1 : 4
        ContainerVolume(ind) = (SortedWaterLevels(ind + 1, 2) - SortedWaterLevels(ind, 2))  * AreaSize * ind;
    end
    ContainerVolume(5) = inf;

    WaterVolume = WaterContentMap(RowPosition, ColumnPosition);
    WaterContentMap(RowPosition, ColumnPosition) = 0;
    
    
    WaterOutflowVolumes(:, 1) = SortedWaterLevels(:, 1);
    WaterOutflowVolumes(:, 2) = [0; 0; 0; 0; 0];
    if WaterVolume <=  ContainerVolume( 1 )
        WaterOutflowVolumes( 1, 2 ) = WaterVolume;
        WaterVolume = 0;
    elseif WaterVolume <=  (ContainerVolume( 1 ) + ContainerVolume( 2 )) && WaterVolume ~= 0
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + (WaterVolume - ContainerVolume( 1 )) / 2;
        WaterOutflowVolumes( 2, 2 ) = (WaterVolume - ContainerVolume( 1 )) / 2;
        WaterVolume = 0;
    elseif WaterVolume <= (ContainerVolume( 1 ) + ContainerVolume( 2 ) + ContainerVolume( 3 )) && WaterVolume ~= 0
        WaterOutflowToThirdArea = (WaterVolume - (ContainerVolume( 1 ) + ContainerVolume( 2 ))) / 3;
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + WaterOutflowToThirdArea;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + WaterOutflowToThirdArea;
        WaterOutflowVolumes( 3, 2 ) = WaterOutflowToThirdArea;
        WaterVolume = 0;
    elseif WaterVolume <=  (ContainerVolume( 1 ) + ContainerVolume( 2 ) + ContainerVolume( 3 ) + ContainerVolume( 4 )) && WaterVolume ~= 0
        WaterOutflowToFourthArea = (WaterVolume - (ContainerVolume( 1 )+ ContainerVolume( 2 ) + ContainerVolume( 3 ))) / 4;
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + WaterOutflowToFourthArea;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + WaterOutflowToFourthArea;
        WaterOutflowVolumes( 3, 2 ) = ContainerVolume( 3 ) / 3 + WaterOutflowToFourthArea;
        WaterOutflowVolumes( 4, 2 ) = WaterOutflowToFourthArea;
        WaterVolume = 0;
    elseif WaterVolume <=  (ContainerVolume( 1 ) + ContainerVolume( 2 ) + ContainerVolume( 3 ) + ContainerVolume( 4 ) + ContainerVolume( 5 )) && WaterVolume ~= 0
        WaterOutflowToFifthArea = (WaterVolume - (ContainerVolume( 1 )+ ContainerVolume( 2 ) + ContainerVolume( 3 ) + ContainerVolume( 4 ))) / 5;
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + ContainerVolume( 4 ) / 4 + WaterOutflowToFifthArea;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + ContainerVolume( 4 ) / 4 + WaterOutflowToFifthArea;
        WaterOutflowVolumes( 3, 2 ) = ContainerVolume( 3 ) / 3 + ContainerVolume( 4 ) / 4 + WaterOutflowToFifthArea;
        WaterOutflowVolumes( 4, 2 ) = ContainerVolume( 4 ) / 4 + WaterOutflowToFifthArea;
        WaterOutflowVolumes( 5, 2 ) = WaterOutflowToFifthArea;
        WaterVolume = 0;
    end

    [~, order] = sort(WaterOutflowVolumes(:, 1));
    WaterOutflowVolumes = WaterOutflowVolumes(order, :);
    
end