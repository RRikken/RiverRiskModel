classdef DikeBreach
    %DIKEBREACH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        %% Afschuiving
        function SafetyFactor = CalculateStability(obj, ShearStress, , Radius, Gravitation, 
      
        %%Sellmeijer Piping midel
        function WaterHeightDifference = CalculateSellmeijer(obj, SeepageLength, ThicknessSandLayer, RollResistanceAngle, TowForceFactor, WeightGrainUnderwater, WeightWater, IntrinsicConductivity, PercentileSand)
            Alpha = CalculateAlpha(ThicknessSandLayer, SeepageLength);
            Beta = CalculateBeta(TowForceFactor, PercentileSand, IntrinsicConductivity, SeepageLength);
            WaterHeightDifference = Alpha*Beta*(WeightGrainUnderwater/WeightWater)*tan(RollResistanceAngle)*(0.68-0.10*log(Beta))*SeepageLength;
        end
        
        function Alpha = CalculateAlpha(obj, ThicknessSandLayer, SeepageLength)
            Alpha = (ThicknessSandLayer/SeepageLength)^(0.28/((ThicknessSandlayer/SeepageLength)^2.8)-1);
        end
        
        function Beta = CalculateBeta(obj, TowForceFactor, PercentileSand, IntrinsicConductivity, SeepageLength)
            Beta = TowForceFactor*PercentileSand*(1/(IntrinsicConductivity*SeepageLength))^(1/3);
        end
    end
end