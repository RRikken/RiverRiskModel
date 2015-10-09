classdef River
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % River dimentions
        WidthSummerBed                       % in meters
        WidthWinterBed                          % in meters
        HeightWinterDike                        % m+NAP
        BottomHeightSummerBed       % m+NAP
        BottomHeightWinterBed          % m+NAP
       Gradient                                             % m/m
        % Riverflow
        FlowTotal                                          % in m3/s
        
        % Constants
        ChezyCoefficient = 0.005;          % chezy waarde zomerbed en winterbed
        GravityConstant = 9.81;               % gravitatie constante in m/s2
        PressureAtmosphere = 10^5;   % atmosferische druk in N/m2
        Rho = 1000;                                       % dichtheid water in kg/m3

        % get properties
        WidthRiverTotal                             % in meters
        DepthSummerBed
        DepthWinterBed
        MaximumFlowSummerBed
        TotalMaximumFlow
        WaterHeightSummerBed
        WaterHeightWinterBed
    end
    
    methods
        function obj = River(WidthSummerBed, WidthWinterBed, HeightWinterDike, BottomHeightSummerBed, BottomHeightWinterBed, Gradient, FlowTotal)
            obj.WidthSummerBed = WidthSummerBed;
            obj.WidthWinterBed  = WidthWinterBed;
            obj.HeightWinterDike  = HeightWinterDike; 
            obj.BottomHeightSummerBed = BottomHeightSummerBed;
            obj.BottomHeightWinterBed = BottomHeightWinterBed;
            obj.Gradient = Gradient;
            obj.FlowTotal = FlowTotal;
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
            MaximumFlowSummerWinterBed = (obj.WidthRiverTotal .* (obj.DepthWinterBed).^1.5) .* ...
                sqrt((obj.GravityConstant.*obj.Gradient) ./ obj.ChezyCoefficient);
            ReturnValueMaximumFlowTotal = obj.MaximumFlowSummerBed + MaximumFlowSummerWinterBed;
        end
        
        function ReturnValueWaterHeigthSummerBed = get.WaterHeightSummerBed(obj)
            %waterhoogte berekening
            ReturnValueWaterHeigthSummerBed = (obj.FlowTotal./(obj.WidthSummerBed.*sqrt(obj.GravityConstant./obj.ChezyCoefficient) ...
                .*sqrt(obj.Gradient))).^(2./3);
        end
        
        function ReturnValueWaterHeightWinterBed = get.WaterHeightWinterBed(obj)
            FlowThroughWinterBed = obj.FlowTotal - obj.MaximumFlowSummerBed;
            CheckForNegativeValues = FlowThroughWinterBed < 0;
            GravityDividedByChezy = obj.GravityConstant  ./ obj.ChezyCoefficient;
            ReturnValueWaterHeightWinterBed = ((FlowThroughWinterBed) ./ (obj.WidthRiverTotal .* sqrt( GravityDividedByChezy ) .* sqrt( obj.Gradient ))) .^(2 / 3);
            ReturnValueWaterHeightWinterBed(CheckForNegativeValues) = 0;
        end
     
        function [ Pressure, HeightSummerBed, HeightWinterBed ] = CalculatePressureAndWaterHeight(obj)
            %Creëren van nulvectoren voor de resultaat-vectoren
            HeightSummerBed = zeros(1,300);
            HeightWinterBed = zeros(1,300);
            Pressure = zeros(1,300);
            
            %Model
            for FlowVectorInd = 1:length(obj.FlowTotal)
                
                if  obj.FlowTotal(FlowVectorInd) <= obj.MaximumFlowSummerBed
                    HeightSummerBed(FlowVectorInd) = obj.BottomHeightSummerBed + obj.WaterHeightSummerBed(FlowVectorInd);
                elseif Qtotaal(FlowVectorInd) >= Qmax_zomerbed
                    HeightWinterBed(FlowVectorInd) = obj.BottomHeightWinterBed  + obj.WaterHeightWinterBed(FlowVectorInd);
                end
                
                if obj.FlowTotal(FlowVectorInd) > obj.TotalMaximumFlow
                    HeightWinterBed(FlowVectorInd) = obj.HeightWinterDike;
                end
                
                if HeightWinterBed(FlowVectorInd) >= obj.BottomHeightWinterBed;
                    Pressure(FlowVectorInd) = obj.PressureAtmosphere  + obj.Rho * obj.GravityConstant * ...
                        (HeightWinterBed(FlowVectorInd) - obj.BottomHeightWinterBed); %[kg/s]= [N/m^2]
                else
                    Pressure(FlowVectorInd) = obj.PressureAtmosphere ;
                end
            end
        end
        
    end
    
end