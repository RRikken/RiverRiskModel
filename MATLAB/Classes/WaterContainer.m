classdef WaterContainer < handle
    %WATERCONTAINER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = immutable)
        RowPosition
        ColumnPosition
        BottomHeight
        AreaSize
    end
    properties
        NeighbourAbove
        NeighbourBelow
        NeighbourLeft
        NeighbourRight
        WaterContents = 0;    % In m^3
        OutFlow = [1 0;2 0;3 0;4 0; 5 0];
        InFlow = [0;0;0;0];
    end
    properties ( Dependent )
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
        
        function obj = AddToWaterContents(obj, FromWhereItCame, OutFlowVolume)
            if strcmp(FromWhereItCame, 'FromAbove') && OutFlowVolume > 0;
                obj.InFlow(1,1) = 1;
            elseif strcmp(FromWhereItCame, 'FromRight') && OutFlowVolume > 0;
                obj.InFlow(2,1) = 1;
            elseif strcmp(FromWhereItCame, 'FromLeft') && OutFlowVolume > 0;
                obj.InFlow(3,1) = 1;
            elseif strcmp(FromWhereItCame, 'FromBelow') && OutFlowVolume > 0;
                obj.InFlow(4,1) = 1;
            end
            if OutFlowVolume < -0.0000000001
                error('OutFlow negative')
            end
            obj.WaterContents = obj.WaterContents + OutFlowVolume;
        end
        
        function [NewObjectsList, WaterOutflowVolumes] = CalculateOutFlows(obj, UpdateList)
            Waterlevels = obj.CheckSurroundingWaterLevels;
            [ RowValuesSortedArray, ~ ] = obj.FindAllWaterLevelsAndSort(Waterlevels);
            WaterOutflowVolumes = obj.DetermineOutflows(RowValuesSortedArray);
            NewObjectsList = uint32.empty();
            for ind = 1 : 4
                SelectedCell = [ NaN NaN ];
                if ind == 1 && WaterOutflowVolumes(1, 2) > 0
                    SelectedCell = [obj.NeighbourAbove.RowPosition, obj.NeighbourAbove.ColumnPosition];
                elseif ind == 2 && WaterOutflowVolumes(2, 2) > 0
                    SelectedCell = [obj.NeighbourLeft.RowPosition, obj.NeighbourLeft.ColumnPosition];
                elseif ind == 3 && WaterOutflowVolumes(3, 2) > 0
                    SelectedCell = [obj.NeighbourRight.RowPosition, obj.NeighbourRight.ColumnPosition];
                elseif ind == 4 && WaterOutflowVolumes(4, 2) > 0
                    SelectedCell = [obj.NeighbourBelow.RowPosition, obj.NeighbourBelow.ColumnPosition];
                end
                
                n=floor(log10(SelectedCell(2)));
                UniqueID = 10^(n+1)*SelectedCell(1) + SelectedCell(2);
                
%                 UniqueID = str2num(sprintf('%d%d',SelectedCell(1),SelectedCell(2)));
                UniqueIDsUpdateList = UpdateList(:,3);
                IsIDInUpdateList = NaN;
                if isempty(UniqueID) == 0
                    ListLogical = UniqueIDsUpdateList == UniqueID;
                    IsIDInUpdateList = any(ListLogical);
                end
                if IsIDInUpdateList == 0 && any(isnan(SelectedCell)) == 0
                    SelectedCell = [ SelectedCell UniqueID];
                    NewObjectsList = [ NewObjectsList; SelectedCell];
                end
            end
        end
        
        function OutflowToOtherContainersAndRetention( obj )
            if isobject(obj.NeighbourAbove) == 1
                obj.NeighbourAbove.AddToWaterContents('FromBelow', obj.OutFlow(1,2));
                obj.OutFlow(1,2) = 0;
            end
            if isobject(obj.NeighbourLeft) == 1
                obj.NeighbourLeft.AddToWaterContents('FromRight', obj.OutFlow(2,2));
                obj.OutFlow(2,2) = 0 ;
            end
            if isobject(obj.NeighbourRight) == 1
                obj.NeighbourRight.AddToWaterContents('FromLeft', obj.OutFlow(3,2));
                obj.OutFlow(3,2) = 0;
            end
            if isobject(obj.NeighbourBelow) == 1
                obj.NeighbourBelow.AddToWaterContents('FromAbove', obj.OutFlow(4,2));
                obj.OutFlow(4,2) = 0;
            end
            obj.WaterContents = obj.WaterContents + obj.OutFlow(5,2);
            obj.OutFlow(5,2) = 0;
            if sum(obj.OutFlow(:,2)) > 0
                obj.WaterContents = obj.WaterContents + sum(obj.OutFlow(:,2));
                obj.OutFlow(1:5,2) = 0;
            elseif sum(obj.OutFlow(:,2)) < -0.0000001
                error('Ouflow is smaller then zero')
            end
        end
        
        function SurroundingWaterLevels = CheckSurroundingWaterLevels(obj)
            if isobject(obj.NeighbourAbove) == 1
                SurroundingWaterLevels(1,1) = obj.NeighbourAbove.WaterLevel;
            else
                SurroundingWaterLevels(1,1) = NaN;
            end
            if isobject(obj.NeighbourLeft) == 1
                SurroundingWaterLevels(2,1) = obj.NeighbourLeft.WaterLevel;
            else
                SurroundingWaterLevels(2,1) = NaN;
            end
            if isobject(obj.NeighbourRight) == 1
                SurroundingWaterLevels(3,1) = obj.NeighbourRight.WaterLevel;
            else
                SurroundingWaterLevels(3,1) = NaN;
            end
            if isobject(obj.NeighbourBelow) == 1
                SurroundingWaterLevels(4,1) = obj.NeighbourBelow.WaterLevel;
            else
                SurroundingWaterLevels(4,1) = NaN;
            end
        end
        
        function [ SortedWaterLevels, AllWaterLevels ]  = FindAllWaterLevelsAndSort(obj, SurroundingWaterLevels )
            AllWaterLevels = [ 1 0; 2 0; 3 0; 4 0; 5 0];
            AllWaterLevels(1 : 4, 2) = SurroundingWaterLevels;
            AllWaterLevels(5, 2) = obj.WaterLevel;
            SurroundingWaterLevels(obj.InFlow == 1 ) = NaN;
            SurroundingWaterLevels(5,1) = obj.WaterLevel;
            SortedWaterLevels(:,1) =  1:5;
            SortedWaterLevels(:,2) = SurroundingWaterLevels;
            [~, order] = sort(SortedWaterLevels(:, 2));
            SortedWaterLevels = SortedWaterLevels(order, :);
        end
        
        function [WaterOutflowVolumes, obj] = DetermineOutflows(obj, SortedWaterLevels)
            WaterOutflowVolumes(:, 1) = SortedWaterLevels(:, 1);
            WaterOutflowVolumes(:, 2) = [0; 0; 0; 0; 0];
            
            if obj.WaterLevel > SortedWaterLevels(1)
                NumberOfContainers = 5 - sum(isnan(SortedWaterLevels(:, 2)));
                if SortedWaterLevels(1,2) < obj.BottomHeight;
                    % This is waterheight because the bottom is higher then the lowest waterheight
                    % in the other containers
                    WaterVolume = obj.WaterContents;
                    obj.WaterContents = 0;
                    [~, order] = sort(SortedWaterLevels(:, 1));
                    SortedWaterLevels = SortedWaterLevels(order, :);
                    SortedWaterLevels(5) = obj.BottomHeight;
                    [~, order] = sort(SortedWaterLevels(:, 2));
                    SortedWaterLevels = SortedWaterLevels(order, :);
                else
                    % This is the waterlevel because bottomheight + waterheight = level
                    if obj.WaterLevel < SortedWaterLevels(1,2)
                        error('Waterlevel too low')
                    end
                    DifferenceInWaterLevel = obj.WaterLevel - SortedWaterLevels(1,2);
                   WaterVolume = DifferenceInWaterLevel * obj.AreaSize;
                    % Take the water that needs to be divided out of the container
                    obj.WaterContents = obj.WaterContents - WaterVolume;
                    if obj.WaterContents < -0.00000001
                        error('WaterContents cannot be lower then 0')
                    end
                   % Reset to the new waterlevel
                    [~, order] = sort(SortedWaterLevels(:, 1));
                    SortedWaterLevels = SortedWaterLevels(order, :);
                    SortedWaterLevels(5) = obj.WaterLevel;
                    [~, order] = sort(SortedWaterLevels(:, 2));
                    SortedWaterLevels = SortedWaterLevels(order, :);
                end
                
                ContainerVolume(1 : 5,1) = 0;
                
                for ind = 1 : NumberOfContainers
                    if ind + 1 > NumberOfContainers
                        ContainerVolume(ind,1) = Inf;
                    else
                        ContainerVolume(ind,1) = (SortedWaterLevels(ind + 1, 2) - SortedWaterLevels(ind, 2) ) * obj.AreaSize * ind;
                    end
                end
                
                for ind = 1 : NumberOfContainers
                    if sum( ContainerVolume( 1 : ind) ) > WaterVolume
                        WaterOutflowVolumes(1 : ind - 1, 2) = ContainerVolume(1 : ind - 1, 1);
                        if ind > 1
                            WaterOutflowVolumes(ind, 2) =WaterVolume - sum(ContainerVolume(1 : ind - 1, 1));
                        elseif ind == 1
                            WaterOutflowVolumes(ind, 2) =WaterVolume;
                        end
                    end
                    if WaterOutflowVolumes(ind, 2) < -0.0000001
                        error('Outflow cannot be negative')
                    end
                    if sum(WaterOutflowVolumes(:,2)) > WaterVolume - 0.01 && sum(WaterOutflowVolumes(:,2)) < WaterVolume + 0.01
                        break;
                        %                     elseif sum(WaterOutflowVolumes(:,2)) > WaterVolume
                        %                         error('Wateroutflow exceeds water available.')
                    end
                end
            end
            WaterOutflowVolumes = sortrows(WaterOutflowVolumes, 1);
        end
    end
end