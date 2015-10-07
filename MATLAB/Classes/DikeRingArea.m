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
        function obj = DikeRingArea(Number, Landusage, AverageHeightMap, MaximumHeightMap, Inhabitants)
            obj.Number = Number;
            obj.Landusage = Landusage;
            obj.AverageHeightMap = AverageHeightMap;
            obj.MaximumHeightMap = MaximumHeightMap;
            obj.Inhabitants = Inhabitants;
        end
        
        function FloodDepth = CalculateFloodDepth(obj, FloodDepth)
            FloodDepth = FloodDepth - obj.AverageHeightMap;
            FloodDepth(FloodDepth < 0) = 0;
        end
    end
    
    methods(Static)
        function PlotArea(HeigthMap)
            [n_Y,n_X] = size(HeigthMap);
            surf([1:n_X], [1:n_Y],flipud(HeigthMap),'EdgeColor','none'); view(2); colorbar; axis equal;
            axis([0 1000 -100 300])
            xlabel('x (100 m)')
            ylabel('y (100 m)')
            title('Dijkringgebieden')
        end
    end
end