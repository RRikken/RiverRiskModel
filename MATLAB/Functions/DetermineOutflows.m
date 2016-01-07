function [ WaterOutflowVolumes ] = DetermineOutflows( SortedBottomLevels, WaterVolume, AreaSize )
     
    ContainerVolume = zeros(1,4);
    WaterOutflowVolumes = zeros(4,2);
    
    for ind = 1 : 3
        ContainerVolume(ind) = (SortedBottomLevels(ind + 1, 2) - SortedBottomLevels(ind, 2))  * AreaSize * ind;
    end
    ContainerVolume(4) = inf;
        
    WaterOutflowVolumes(:, 1) = SortedBottomLevels(:, 1);
   
    if WaterVolume <=  ContainerVolume( 1 )
        WaterOutflowVolumes( 1, 2 ) = WaterVolume;
    elseif WaterVolume <=  (ContainerVolume( 1 ) + ContainerVolume( 2 )) && WaterVolume ~= 0
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + (WaterVolume - ContainerVolume( 1 )) / 2;
        WaterOutflowVolumes( 2, 2 ) = (WaterVolume - ContainerVolume( 1 )) / 2;
    elseif WaterVolume <= (ContainerVolume( 1 ) + ContainerVolume( 2 ) + ContainerVolume( 3 )) && WaterVolume ~= 0
        WaterOutflowToThirdArea = (WaterVolume - (ContainerVolume( 1 ) + ContainerVolume( 2 ))) / 3;
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + WaterOutflowToThirdArea;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + WaterOutflowToThirdArea;
        WaterOutflowVolumes( 3, 2 ) = WaterOutflowToThirdArea;
    elseif WaterVolume <=  (ContainerVolume( 1 ) + ContainerVolume( 2 ) + ContainerVolume( 3 ) + ContainerVolume( 4 )) && WaterVolume ~= 0
        WaterOutflowToFourthArea = (WaterVolume - (ContainerVolume( 1 )+ ContainerVolume( 2 ) + ContainerVolume( 3 ))) / 4;
        WaterOutflowVolumes( 1, 2 ) = ContainerVolume( 1 ) + ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + WaterOutflowToFourthArea;
        WaterOutflowVolumes( 2, 2 ) = ContainerVolume( 2 ) / 2 + ContainerVolume( 3 ) / 3 + WaterOutflowToFourthArea;
        WaterOutflowVolumes( 3, 2 ) = ContainerVolume( 3 ) / 3 + WaterOutflowToFourthArea;
        WaterOutflowVolumes( 4, 2 ) = WaterOutflowToFourthArea;
    end

    [~, order] = sort(WaterOutflowVolumes(:, 1));
    WaterOutflowVolumes = WaterOutflowVolumes(order, :);
    
end