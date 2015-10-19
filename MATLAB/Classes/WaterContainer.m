classdef WaterContainer
    %WATERCONTAINER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = immutable)
        RowPosition
        ColumnPosition
        BottomHeight
        AreaSize
    end
    properties
        WaterContents = 0;    % In m^3
        OutFlow = [0; 0; 0; 0; 0 ];
        InFlow = [0; 0; 0; 0; 0 ];
    end
     properties ( Dependent )
        WaterHeight                                 % In meters from bottomheight
        WaterLevel                                    %
        NeighbourList
    end
    
    methods
        function obj = WaterContainer(RowPosition, ColumnPosition, BottomHeight, AreaSize)
            if nargin==0
                obj.RowPosition= NaN;
                obj.ColumnPosition = NaN;
                obj.BottomHeight = NaN;
                obj.AreaSize = NaN;
                obj.WaterContents = NaN;
            else
                obj.RowPosition= uint32(RowPosition);
                obj.ColumnPosition = uint32(ColumnPosition);
                obj.BottomHeight = BottomHeight;
                obj.AreaSize = AreaSize;
                obj.WaterContents = 0;
            end
        end
        
        function ReturnedWaterHeight = get.WaterHeight(obj)
            ReturnedWaterHeight = obj.WaterContents / obj.AreaSize;
        end
        
        function ReturnedWaterLevel = get.WaterLevel(obj)
            ReturnedWaterLevel = obj.BottomHeight + obj.WaterHeight;
        end
        
        function ReturnedNeighbours = get.NeighbourList(obj)
            ReturnedNeighbours(1,1) = [ obj.RowPosition - 1, obj.ColumnPosition ];
            ReturnedNeighbours(2,1) = [ obj.RowPosition, obj.ColumnPosition - 1];
            ReturnedNeighbours(3,1) = [ obj.RowPosition, obj.ColumnPosition + 1];
            ReturnedNeighbours(4,1) = [ obj.RowPosition + 1, obj.ColumnPosition];
        end
        
        function obj = set.OutFlow(obj,OutFlowVolumes)
            obj.OutFlow = OutFlowVolumes;
        end
        
        function obj = set.InFlow(obj, OutFlowVolumeAndPosition)
            
            if length(OutFlowVolumeAndPosition) == 1
                obj.InFlow(5) = OutFlowVolume;
            else
                if OutFlowVolumeAndPosition(1) == obj.RowPosition - 1 && OutFlowVolumeAndPosition(2) == obj.ColumnPosition;
                    obj.InFlow(1) = OutFlowVolumeAndPosition(3);
                elseif OutFlowVolumeAndPosition(1) == obj.RowPosition  && OutFlowVolumeAndPosition(2) == obj.ColumnPosition - 1;
                    obj.InFlow(2) = OutFlowVolumeAndPosition(3);
                elseif OutFlowVolumeAndPosition(1) == obj.RowPosition  && OutFlowVolumeAndPosition(2) == obj.ColumnPosition + 1;
                    obj.InFlow(3) = OutFlowVolumeAndPosition(3);
                elseif OutFlowVolumeAndPosition(1) == obj.RowPosition + 1 && OutFlowVolumeAndPosition(2) == obj.ColumnPosition;
                    obj.InFlow(4) = OutFlowVolumeAndPosition(3);
                end
            end
        end
        
        function [WaterContainerMap, NewObjectsList] = CalculateOutFlows(obj, UpdateList, WaterContainerMap)
            [WaterContainerMap, Waterlevels] =obj.CheckSurroundingWaterLevels(WaterContainerMap);
            [ RowValuesSortedArray, AllWaterLevels ] = obj.CalculateVolumeForContainer(Waterlevels);
            WaterOutflowVolumes = obj.DetermineOutflows(RowValuesSortedArray, AllWaterLevels);
            
            for ind = 1 : length(WaterOutflowVolumes)
                if WaterOutflowVolumes(ind, 2) > 0
                    SelectedCell = [obj.NeighbourList(ind,1) obj.NeighbourList(ind,2)];
                    [Lia, Locb] = ismember(SelectedCell,UpdateList, 'rows');
                end
            end
            obj.OutFlow = WaterOutflowVolumes;
        end
        
        function WaterContainerMap = OutflowToOtherContainersAndRetention(obj, WaterContainerMap )
            for i = 1 : 5
                if obj.OutFlow(i,2) > 0
                    switch i
                        case 1
                            OutFlowAndPosition = [obj.RowPosition, obj.ColumnPosition, obj.OutFlow(1,2)];
                            WaterContainerMap(obj.RowPosition - 1, obj.ColumnPosition).InFlow(OutFlowAndPosition);
                        case 2
                            OutFlowAndPosition = [obj.RowPosition, obj.ColumnPosition, obj.OutFlow(2,2)];
                            WaterContainerMap( obj.RowPosition, obj.ColumnPosition - 1 ).InFlow = OutFlowAndPosition;
                        case 3
                            OutFlowAndPosition = [obj.RowPosition, obj.ColumnPosition, obj.OutFlow(3,2)];
                            WaterContainerMap(obj.RowPosition, obj.ColumnPosition + 1).InFlow = OutFlowAndPosition;
                        case 4
                            OutFlowAndPosition = [obj.RowPosition, obj.ColumnPosition, obj.OutFlow(4,2)];
                            WaterContainerMap(obj.RowPosition + 1, obj.ColumnPosition).InFlow = OutFlowAndPosition;
                        case 5
                            obj.WaterContents = obj.WaterContents + obj.OutFlow(5,2);
                    end
                end
            end
        end
        
        function [WaterContainerMap, SurroundingWaterLevels] = CheckSurroundingWaterLevels(obj, WaterContainerMap)
            SurroundingWaterLevels(1,1) = WaterContainerMap(obj.RowPosition - 1, obj.ColumnPosition).WaterLevel;
            SurroundingWaterLevels(2,1) = WaterContainerMap(obj.RowPosition , obj.ColumnPosition - 1).WaterLevel;
            SurroundingWaterLevels(3,1) = WaterContainerMap(obj.RowPosition, obj.ColumnPosition + 1).WaterLevel;
            SurroundingWaterLevels(4,1) = WaterContainerMap(obj.RowPosition + 1, obj.ColumnPosition).WaterLevel;
        end
        
        function [ RowValuesSortedArray, AllWaterLevels ]  = CalculateVolumeForContainer(obj, SurroundingWaterLevels )
            AllWaterLevels = zeros(5,2);
            AllWaterLevels(1  :  4, 2) = SurroundingWaterLevels;
            AllWaterLevels(5, 2) = obj.WaterLevel;
            AllWaterLevels(1:5,1) = [ 1 2 3 4 5];
            
            SurroundingWaterLevels = AllWaterLevels;
            InFlowLogical = false(5,2);
            InFlowLogical(:,2) = obj.InFlow ~= 0;
            SurroundingWaterLevels(InFlowLogical) = NaN;
            RowValuesSortedArray = sortrows(SurroundingWaterLevels, 2);
        end
        
        function [WaterOutflowVolumes, obj] = DetermineOutflows(obj, RowValuesSortedArray, AllWaterLevels)
            WaterOutflowVolumes = zeros(length(AllWaterLevels), 1);
            WaterVolume = sum(obj.InFlow, 'omitnan');
            DivideWaterToContainers = zeros(length(AllWaterLevels), 2);
            DivideWaterToContainers(:,1) = RowValuesSortedArray(:,1);
            k = 1;
            while WaterVolume > 0
                StepWaterVolume = ( RowValuesSortedArray(k + 1, 2) - RowValuesSortedArray(k , 2) ) * obj.AreaSize;
                VolumePerContainer = StepWaterVolume / k;
                StepWaterVolumeArray = zeros(5,1);
                StepWaterVolumeArray(1:k) = VolumePerContainer;
                DivideWaterToContainers(:, 2) = DivideWaterToContainers(:, 2) + StepWaterVolumeArray;
                WaterVolume = WaterVolume - StepWaterVolume;
                
                if WaterVolume < 0
                    WaterToMuch = zeros(5,1);
                    WaterToMuch(1:k) = WaterVolume / k;
                    DivideWaterToContainers(1:5, 2) = DivideWaterToContainers(1:5, 2) + WaterToMuch;
                end
                if k > 100
                    debug;
                end
            end
            WaterOutflowVolumes = sortrows(DivideWaterToContainers, 1);
        end
    end
    
end