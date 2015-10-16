classdef WaterContainer
    %WATERCONTAINER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        WaterContents                            % In m^3
        RowPosition
        ColumnPosition
        OutFlow
        InFlow
        BottomHeight
        AreaSize
        
        % Get properties
        WaterHeight                                 % In meters from bottomheight
        WaterLevel                                    %
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
                obj.RowPosition= RowPosition;
                obj.ColumnPosition = ColumnPosition;
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
        
        function [WaterContainerMap, UpdateList] = CalculateOutFlows(obj, UpdateList, WaterContainerMap)
            [WaterContainerMap, Waterlevels] =obj.CheckSurroundingWaterLevels(WaterContainerMap);
            [ RowValuesSortedArray, AllWaterLevels ] = obj.CalculateVolumeForContainer(Waterlevels);
            WaterOutflowVolumes = obj.DetermineOutflows(RowValuesSortedArray, AllWaterLevels);
            WaterContainerMap = OutflowToOtherContainersAndRetention( WaterOutflowVolumes, WaterContainerMap );
            UpdateList = UpdateList + NewListItems;
        end
        
        function WaterContainerMap = OutflowToOtherContainersAndRetention(obj, WaterOutflowVolumes, WaterContainerMap )
            for i = 1 : length(WaterOutflowVolumes)
                if WaterOutflowVolumes(i) > 0
                    switch i
                        case 1
                            WaterContainerMap{obj.RowPosition - 1, obj.ColumnPosition}.WaterInflow(obj.RowPosition, obj.ColumnPosition, Volume);
                        case 2
                            WaterContainerMap{obj.RowPosition, obj.ColumnPosition - 1}.WaterInflow(obj.RowPosition, obj.ColumnPosition, Volume);
                        case 3
                            WaterContainerMap{obj.RowPosition, obj.ColumnPosition + 1}.WaterInflow(obj.RowPosition, obj.ColumnPosition, Volume);
                        case 4
                            WaterContainerMap{obj.RowPosition + 1, obj.ColumnPosition}.WaterInflow(obj.RowPosition, obj.ColumnPosition, Volume);
                        case 5
                            obj.WaterContents = obj.WaterContents + Volume;
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
            SurroundingWaterLevels(isnan(obj.InFlow) == 0) = NaN;
            AllWaterLevels = zeros(5,1);
            AllWaterLevels(1 : 4) = SurroundingWaterLevels;
            AllWaterLevels(5) = obj.WaterLevel;
            SortArray = AllWaterLevels;
            k = 1;
            while isnan(min(SortArray, [], 'omitnan')) == 0
                [MinValue,RowIndex] = min(SortArray, [], 'omitnan');
                RowValuesSortedArray(k,1) = RowIndex;
                RowValuesSortedArray(k,2) = MinValue;
                SortArray(RowIndex,1) = NaN;
                k = k + 1;
            end
        end
        
        function WaterOutflowVolumes = DetermineOutflows(obj, RowValuesSortedArray, AllWaterLevels)
            WaterOutflowVolumes = zeros(length(AllWaterLevels), 1);
            WaterVolume = sum(obj.InFlow, 'omitnan');
            DivideWaterToContainers = zeros(length(AllWaterLevels), 1);
            k = 1;
            while WaterVolume > 0
                StepWaterVolume = ( RowValuesSortedArray(k + 1, 2) - RowValuesSortedArray(k , 2) ) * obj.AreaSize;
                VolumePerContainer = StepWaterVolume / k;
                StepWaterVolumeArray = zeros(5,1);
                StepWaterVolumeArray(1:k) = VolumePerContainer;
                DivideWaterToContainers = DivideWaterToContainers + StepWaterVolumeArray;
                WaterVolume = WaterVolume - StepWaterVolume;
                if k > 1000
                    debug;
                end
            end
            
            for m = length(DivideWaterToContainers);
                WaterOutflowVolumes(RowValuesSortedArray(m,2), 1) = DivideWaterToContainers(m, 1);
            end
        end
    end
    
end