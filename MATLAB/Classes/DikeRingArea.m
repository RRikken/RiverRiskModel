classdef DikeRingArea
    %DIKERINGAREA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Landusage
        Number
        AverageHeightMap
        MaximumHeightMap
        Inhabitants
    end
    
    methods
        function PlotArea(obj)
            
            [n_Y,n_X] = size(obj.Landusage);
            surf([1:n_X], [1:n_Y],flipud(obj.AverageHeightMap),'EdgeColor','none'); view(2); colorbar; axis equal;
            axis([0 1000 -100 300])
            xlabel('x (100 m)')
            ylabel('y (100 m)')
            title('Dijkringgebieden')
        end
    end
end