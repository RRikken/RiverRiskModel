classdef River
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        WidthSummerBed                       % in meters
        WidthWinterBed                          % in meters
        HeightWinterDike                        % m+NAP
        BottomHeightSummerBed       % m+NAP
        BottomHeightWinterBed          % m+NAP
       Gradient                                             % m/m
        FlowTotal                                          % in m3/s
        DivisionOfWater
    end
        
    properties (Constant)
        ChezyCoefficient = 0.005;          % chezy waarde zomerbed en winterbed
        GravityConstant = 9.81;               % gravitatie constante in m/s2
        PressureAtmosphere = 10^5;   % atmosferische druk in N/m2
        Rho = 1000;                                       % dichtheid water in kg/m3
        a = 1316.4;                                         %komt uit TRontwerp pag.76-77 (2001)
        c = 6612.6;                                         %komt uit TRontwerp pag.76-77 (2001)
    end
   
    properties (Dependent)
        WidthRiverTotal                          
        DepthSummerBed
        DepthWinterBed
        MaximumFlowSummerBed
        TotalMaximumFlow
    end
    
    methods
        function obj = River(WidthSummerBed, WidthWinterBed, HeightWinterDike, BottomHeightSummerBed, BottomHeightWinterBed, Gradient, FlowTotal, DivisionOfWater)
            obj.WidthSummerBed = WidthSummerBed;
            obj.WidthWinterBed  = WidthWinterBed;
            obj.HeightWinterDike  = HeightWinterDike; 
            obj.BottomHeightSummerBed = BottomHeightSummerBed;
            obj.BottomHeightWinterBed = BottomHeightWinterBed;
            obj.Gradient = Gradient;
            obj.FlowTotal = FlowTotal;
            obj.DivisionOfWater = DivisionOfWater;
        end
        
        function ReturnValueWidthRiverTotal = get.WidthRiverTotal(obj)
            ReturnValueWidthRiverTotal = obj.WidthSummerBed + obj.WidthWinterBed;
        end
        
        function ReturnValueDepthSummerBed = get.DepthSummerBed(obj)
            %Omzetten bodemhoogtes naar diepte
            ReturnValueDepthSummerBed = obj.BottomHeightWinterBed - obj. BottomHeightSummerBed;
        end
        
        function ReturnValueDepthWinterBed = get.DepthWinterBed(obj)
            %Omzetten bodemhoogtes naar diepte
            ReturnValueDepthWinterBed = obj.HeightWinterDike - obj.BottomHeightWinterBed;
        end
        
        function ReturnValueMaximumFlowSummerBed = get.MaximumFlowSummerBed(obj)
            %maximale afvoeren
            ReturnValueMaximumFlowSummerBed = (obj.WidthSummerBed .* (obj.DepthSummerBed) .^1.5 ) .* ...
                sqrt((obj.GravityConstant .* obj.Gradient) ./ obj.ChezyCoefficient);
        end
        
        function ReturnValueMaximumFlowTotal = get.TotalMaximumFlow(obj)
            %maximale afvoeren
            MaximumFlowSummerWinterBed = (obj.WidthRiverTotal .* (obj.DepthWinterBed).^1.5) .* ...
                sqrt((obj.GravityConstant.*obj.Gradient) ./ obj.ChezyCoefficient);
            ReturnValueMaximumFlowTotal = obj.MaximumFlowSummerBed + MaximumFlowSummerWinterBed;
        end
        
        function ReturnValueWaterHeigthSummerBed = WaterHeightSummerBed(obj, WaveLobith)
            %waterhoogte berekening
            ReturnValueWaterHeigthSummerBed = (WaveLobith ./ (obj.WidthSummerBed .* sqrt(obj.GravityConstant...
                ./obj.ChezyCoefficient) .* sqrt(obj.Gradient))) .^ (2 / 3);
        end
        
        function ReturnValueWaterHeightWinterBed = WaterHeightWinterBed(obj, WaveLobith)
%             FlowThroughWinterBed = obj.FlowTotal - obj.MaximumFlowSummerBed;
%             CheckForNegativeValues = FlowThroughWinterBed < 0;
            GravityDividedByChezy = obj.GravityConstant  ./ obj.ChezyCoefficient;
            ReturnValueWaterHeightWinterBed = (( WaveLobith - obj.MaximumFlowSummerBed ) ./ (obj.WidthRiverTotal ...
                .* sqrt( GravityDividedByChezy ) .* sqrt( obj.Gradient ))) .^(2 / 3);
%             ReturnValueWaterHeightWinterBed(CheckForNegativeValues) = 0;
        end
     
        function [ Pressure, WaveRepeatTime, WaterHeightSummerBed, WaterHeightWinterBed ] = CalculatePressureAndWaterHeight(obj, WaveLobith)
            %Creëren van nulvectoren voor de resultaat-vectoren
            WaterHeightSummerBed = obj.WaterHeightSummerBed(WaveLobith);
            WaterHeightWinterBed = obj.WaterHeightWinterBed(WaveLobith);
            Pressure = zeros(1, length(WaveLobith));
            WaveRepeatTime = zeros(1, length(WaveLobith));
            
            %Model
            for FlowVectorInd = 1:length(WaveLobith)
                
                if  WaveLobith(FlowVectorInd) <= obj.MaximumFlowSummerBed
                    WaterHeightSummerBed(FlowVectorInd) = obj.BottomHeightSummerBed + WaterHeightSummerBed(FlowVectorInd);
                elseif WaveLobith(FlowVectorInd) >= obj.MaximumFlowSummerBed
                    WaterHeightWinterBed(FlowVectorInd) = obj.BottomHeightWinterBed  + WaterHeightWinterBed(FlowVectorInd);
                end
                
                if WaveLobith(FlowVectorInd) > obj.TotalMaximumFlow
                    WaterHeightWinterBed(FlowVectorInd) = obj.HeightWinterDike;
                end
                
                if WaterHeightWinterBed(FlowVectorInd) >= obj.BottomHeightWinterBed;
                    Pressure(FlowVectorInd) = obj.PressureAtmosphere  + obj.Rho * obj.GravityConstant * ...
                        (WaterHeightWinterBed(FlowVectorInd) - obj.BottomHeightWinterBed); %[kg/s]= [N/m^2]
                else
                    Pressure(FlowVectorInd) = obj.PressureAtmosphere ;
                end
                WaveRepeatTime(FlowVectorInd) = exp((WaveLobith(FlowVectorInd) - obj.DivisionOfWater .* obj.c) ./ (obj.DivisionOfWater .* obj.a));            
            end
        end
    end
    
end