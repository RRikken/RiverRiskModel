classdef BreachFlowModel < handle 
    %BREACHFLOWMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = public)
        WidthBreach
        HeightBreach
        InsideWaterHeightMeasuringLocation
    end
    
    properties (Access = public)
        WaterLevelRiver
        WaterLevelDikeRingArea
    end
    
    properties (Access = private, Dependent)
        WaterLevelDifference
        WaterLevelInsideBreach
        WaterLevelOutsideBreach
    end
    
    properties (Access = private, Constant)
        Gravity = 9.81;
    end
    
    methods
        function obj = BreachFlowModel(WidthBreach, HeightBreach, InsideWaterHeightMeasuringLocation)
            obj.WidthBreach = WidthBreach;
            obj.HeightBreach = HeightBreach;
            obj.InsideWaterHeightMeasuringLocation = InsideWaterHeightMeasuringLocation;
            obj.WaterLevelRiver = 0;
            obj.WaterLevelDikeRingArea = 0;
        end
        
        function ReturnedWaterLevelDifference =  get.WaterLevelDifference(obj)
            ReturnedWaterLevelDifference = obj.WaterLevelRiver - obj.WaterLevelDikeRingArea;
        end
        function ReturnedWaterLevelInsideBreach = get.WaterLevelInsideBreach(obj)
            ReturnedWaterLevelInsideBreach = obj.WaterLevelDikeRingArea - obj.HeightBreach;
        end
        function ReturnedWaterLevelOutsideBreach = get.WaterLevelOutsideBreach(obj)
            ReturnedWaterLevelOutsideBreach = obj.WaterLevelRiver - obj.HeightBreach;
        end
        
        function FlowThroughBreach = CalculateFlowThroughBreach(obj)
            % Debietformule (Visser, 1998; Ren, 2012)
            % Qbres = 	(2/3)^1,5 ? g^0,5 ? Bbres ? hbr_uit^1,5	als hbr_in  < ? ? hbr_uit	ongestuwde instroom
            % Qbres = 	(2?g)^0,5 ? Bbres ?  ?h^0,5? hbr_in als hbr_in  > ? ? hbr_uit	gestuwde instroom
            
            if obj.WaterLevelInsideBreach < ((2/3) * obj.WaterLevelOutsideBreach)
                FlowThroughBreach = (2/3)^(1.5) * obj.Gravity^(0.5) * obj.WidthBreach * obj.WaterLevelOutsideBreach^(1.5);
            elseif obj.WaterLevelInsideBreach >= ((2/3) * obj.WaterLevelOutsideBreach)
                FlowThroughBreach = ((2 * obj.Gravity)^0.5) * obj.WidthBreach * obj.WaterLevelDifference^(0.5) * obj.WaterLevelInsideBreach;
            else
                debug
            end
            if FlowThroughBreach < 0 || isreal(FlowThroughBreach) == 0
                FlowThroughBreach = 0;
            end
        end
    end
    
end