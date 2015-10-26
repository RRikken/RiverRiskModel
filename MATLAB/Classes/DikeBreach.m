classdef DikeBreach
    %DIKEBREACH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ThicknessSandLayer = 50;
        SeepageLength = 63.22;
        WeightWater = 1000;
        WeightGrain = 2000;
        RollResistanceAngle = 41*(pi/180);
        TowForceFactor = 0.25;
        PercentileSand = 0.000266;
        ConductivitySand = 1.16e-4;
        Gravitation = 9.81;
        HydraulicConductivity = 1.32*10^-6;
    end
    
    methods
  
      
  %Sellmeijer Piping model
        function WaterHeightDifference = CalculateSellmeijer(obj, SeepageLength, ThicknessSandLayer, RollResistanceAngle, TowForceFactor, WeightGrainUnderwater, WeightWater, IntrinsicConductivity, PercentileSand, HydraulicConductivity, Gravitation, ConductivitySand)
            Alpha = CalculateAlpha(ThicknessSandLayer, SeepageLength);
            Beta = CalculateBeta(TowForceFactor, PercentileSand, IntrinsicConductivity, SeepageLength);
            IntrinsicConductivity = CalculateIntrinsicConductivity(HydraulicConductivity, Gravitation, ConductivitySand); 
            WaterHeightDifference = Alpha*Beta*(WeightGrainUnderwater/WeightWater)*tan(RollResistanceAngle)*(0.68-0.10*log(Beta))*SeepageLength;
        end
        
        function IntrinsicConductivity = CalculateIntrinsicConductivity(obj, HydraulicConductivity, Gravitation, ConductivitySand)
                IntrinsicConductivity = (HydraulicConductivity/Gravitation)*ConductivitySand;
        end
        
        function Alpha = CalculateAlpha(obj, ThicknessSandLayer, SeepageLength)
            Alpha = (ThicknessSandLayer/SeepageLength)^(0.28/((ThicknessSandlayer/SeepageLength)^2.8)-1);
        end
        
        function Beta = CalculateBeta(obj, TowForceFactor, PercentileSand, IntrinsicConductivity, SeepageLength)
            Beta = TowForceFactor*PercentileSand*(1/(IntrinsicConductivity*SeepageLength))^(1/3);
        end
        
       
            
    end
end