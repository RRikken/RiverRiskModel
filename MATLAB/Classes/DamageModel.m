classdef DamageModel
    %SCHADEMODEL Dit model berekend de overstromingsschade in een dijkringgebied
    %   Detailed explanation goes here
    
    properties
        NumberOfUnitsTable
        MaximumDamageTable
        FloodDepth
        FlowRate
        RiseRate
        ShelterFactor
        Storm
        CriticalFlowRate
        FloodDamage
    end
    
    methods (Static)
       function [TypeOfLandUsage, MaximumDamage ] =  ChangeLandUsageToStandardModelTypes(LandUsage, DamageCategoryTable)
            
            [Rows,Columns] = size(LandUsage);
            TypeOfLandUsage = zeros(Rows,Columns);
            MaximumDamage = zeros(Rows,Columns);
            
            parfor  RowIndex = 1:Rows
                for ColumnIndex = 1:Columns
                    if isnan(LandUsage(RowIndex, ColumnIndex))
                        TypeOfLandUsage(RowIndex, ColumnIndex) = NaN;
                        MaximumDamage(RowIndex, ColumnIndex) = NaN;
                    else
                        TableRow = DamageCategoryTable.DataInputModel == LandUsage(RowIndex, ColumnIndex);
                        TableVars = {'StandardModel', 'MaximalDamage'};
                        NewData = DamageCategoryTable(TableRow, TableVars);
                        TypeOfLandUsage(RowIndex, ColumnIndex) = NewData.StandardModel;
                        MaximumDamage(RowIndex, ColumnIndex) = NewData.MaximalDamage;
                    end
                end
            end
       end
    end
    
    methods    
        function [ TotalDamage, TotalDamageMap ] = CalculateStandardDamageModel(obj, DamageFactors, MaximumDamageValue, NumberOfUnits)
            TotalDamageMap = DamageFactors .* MaximumDamageValue .* NumberOfUnits;
            TotalDamage = sum(sum( TotalDamageMap, 'omitnan'), 'omitnan');
        end
        
        function DamageFactorsMap = SelectDamageFactors(obj, LandUsage, FloodDepth, FlowRate, CriticalFlowRate, ShelterFactor, Storm)
            [Rows,Columns] = size(LandUsage);
            DamageFactorsMap = zeros(Rows,Columns);
            
            for  RowIndex = 1:Rows
                for ColumnIndex = 1:Columns
                    switch LandUsage(RowIndex, ColumnIndex)
                        case 1
                            DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                obj.CalculateDamageFactorAgricultureRecreationAirports(FloodDepth(RowIndex, ColumnIndex));
                        case 2
                            DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                obj.CalculateDamageFactorPumpingStations(FloodDepth(RowIndex, ColumnIndex));
                        case 3
                            DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                obj.CalculateDamageFactorVehicles(FloodDepth(RowIndex, ColumnIndex));
                        case 4
                            DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                obj.CalculateDamageFactorRoadRailways(FloodDepth(RowIndex, ColumnIndex));
                        case 5
                            DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                obj.CalculateDamageFactorGasWaterMains(FloodDepth(RowIndex, ColumnIndex));
                        case 6
                            DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                obj.CalculateDamageFactorElectricityCommunication(FloodDepth(RowIndex, ColumnIndex));
                        case 7
                            DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                obj.CalculateDamageFactorCompanies(FloodDepth(RowIndex, ColumnIndex));
                        case 8
                            DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                obj.CalculateDamageSingleHomesAndFarms(FloodDepth(RowIndex, ColumnIndex),FlowRate(RowIndex, ColumnIndex) ...
                                ,w(RowIndex, ColumnIndex),ShelterFactor(RowIndex, ColumnIndex),Storm,CriticalFlowRate(RowIndex, ColumnIndex));
                        case 9
                            DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                obj.CalculateDamageLowRise(FloodDepth(RowIndex, ColumnIndex), FlowRate(RowIndex, ColumnIndex) ...
                                , Storm, CriticalFlowRate(RowIndex, ColumnIndex), ShelterFactor(RowIndex, ColumnIndex));
                        case 10
                            obj.DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                CalculateDamageFactorMediumRise(FloodDepth(RowIndex, ColumnIndex), FlowRate(RowIndex, ColumnIndex) ...
                                , Storm, CriticalFlowRate(RowIndex, ColumnIndex), ShelterFactor(RowIndex, ColumnIndex));
                        case 11
                            obj.DamageFactorsMap(RowIndex, ColumnIndex) = ...
                                CalaculateDamgaFactorHighRise(FloodDepth(RowIndex, ColumnIndex), FlowRate(RowIndex, ColumnIndex) ...
                                , CriticalFlowRate(RowIndex, ColumnIndex), Storm, ShelterFactor(RowIndex, ColumnIndex));
                        otherwise
                            DamageFactorsMap(RowIndex, ColumnIndex) = NaN;
                    end
                end
            end
        end
        
        function DamageFactorAgricultureRecreationAirports = CalculateDamageFactorAgricultureRecreationAirports(obj, FloodDepth)
            DamageFactorAgricultureRecreationAirports = min([FloodDepth, 0.24 * FloodDepth + 0.4, 0.07 * FloodDepth + 0.75, 1]);
        end
        
        function DamageFactorPumpingStations = CalculateDamageFactorPumpingStations(obj, FloodDepth)
            DamageFactorPumpingStations = min([0.9 * FloodDepth, 0.26 * FloodDepth + 0.28, 1]);
        end
        
        function DamageFactorVehicles = CalculateDamageFactorVehicles(obj, FloodDepth)
            DamageFactorVehicles = min([0.17 * FloodDepth - 0.03, 0.72 * FloodDepth -0.3, 0.31 * FloodDepth + 0.1, 1]);
        end
        
        function DamageFactorRoadAndRailways = CalculateDamageFactorRoadRailways(obj, FloodDepth)
            DamageFactorRoadAndRailways = min([0.28 * FloodDepth, 0.18 * FloodDepth + 0.1, 1]);
        end
        
        function DamageFactorMainsGasWater = CalculateDamageFactorGasWaterMains(obj, FloodDepth)
            DamageFactorMainsGasWater = min([0.8 * FloodDepth, 0.23 * FloodDepth + 0.18, 0.10 * FloodDepth + 0.52, 1]);
        end
        
        function DamageFactorElectricityCommunication = CalculateDamageFactorElectricityCommunication(obj, FloodDepth)
            DamageFactorElectricityCommunication = min([0.8 * FloodDepth, 0.34 * FloodDepth + 0.15, 1]);
        end
        
        function DamageFactorCompanies = CalculateDamageFactorCompanies(obj, FloodDepth)
            if FloodDepth >= 0 && FloodDepth  <= 1
                DamageFactorCompanies = 0.1 * FloodDepth;
            elseif FloodDepth > 1 && FloodDepth <= 3
                DamageFactorCompanies = 0.06 * FloodDepth + 0.04;
            elseif FloodDepth > 3 && FloodDepth <= 5
                DamageFactorCompanies = 0.39 * FloodDepth - 0.95;
            elseif FloodDepth > 5
                DamageFactorCompanies = 1;
            else
                debug;
            end
        end
        
        function DamageSingleHomesAndFarms = CalculateDamageSingleHomesAndFarms(obj, FloodDepth,FlowRate,w,ShelterFactor,Storm,CriticalFlowRate)
            GuilderEuroRatio = 215500 / 315500;
            DamageSingleHomesAndFarms = GuilderEuroRatio * CalculateDamageHouse(FloodDepth,FlowRate,w,ShelterFactor,Storm,CriticalFlowRate) + (1 - GuilderEuroRatio) * CalculateDamageContentsHousehold(FloodDepth,FlowRate,w,ShelterFactor,Storm,CriticalFlowRate);
        end
        
        function DamageFactorLowRise = CalculateDamageLowRise(obj, FloodDepth, FlowRate, Storm, CriticalFlowRate, ShelterFactor)
            if FloodDepth <= 0
                alpha = 0;
            end
            if FlowRate > 0.25 * CriticalFlowRate
                alpha = 1;
            elseif Storm ~= 0 %s <> 0 {ja} then begin
                StormFactor = (0.8E-3 * FloodDepth^1.8 * ShelterFactor );
            else
                StormFactor = 0;
            end
            ExistsStorm = exist('StormFactor',  'var');
            if ExistsStorm == 0 || isempty(StormFactor) == 1
                debug;
            end
            s1 = StormFactor + (1 - StormFactor) * (1 - (1 - max([ 0, min([ FloodDepth, 6 ]) ]) / 6 )^4 );
            alpha = max([0, min([1, s1]) ]);
            DamageFactorLowRise =  alpha;
        end
        
        function DamageFactorMediumRise = CalculateDamageFactorMediumRise(obj, FloodDepth, FlowRate, Storm, CriticalFlowRate, ShelterFactor)
            if FloodDepth <= 0
                alpha = 0;
            if FlowRate > CriticalFlowRate
                alpha = 1;
           elseif Storm ~= 0
                   StormFactor = 0.8E-3 * FloodDepth^1.8 * ShelterFactor;  %Something might be wrong. '> 0.5' was added to the end of the sourcefile;
            else
                    StormFactor = 0;
           end
                s1 = StormFactor + (1 - StormFactor) * (1 - (1 - max([0,min([ FloodDepth, 12 ]) /12 ]))^4);
                alpha = max([0, min([1, s1]) ]);
                DamageFactorMediumRise = alpha;
            end
        end
        
        function DamageFactorHighRise = CalaculateDamgaFactorHighRise(obj, FloodDepth, FlowRate, CriticalFlowRate, Storm, ShelterFactor)
            if FloodDepth <= 0
                alpha = 0;
            elseif FlowRate > CriticalFlowRate
                alpha = 1;
            elseif Storm ~=  0
                StormFactor = 0.4E-3 * FloodDepth^1.8 * ShelterFactor;
            else
                StormFactor = 0;
            end
            s1 = StormFactor + (1 - StormFactor) * (1 - (1 - max([0,min([ FloodDepth, 18 ]) ]) / 18 )^4 );
            alpha = max([ 0 , min([1, s1]) ]);
            DamageFactorHighRise = alpha;
        end
        
        function DamageHouseholdContents = CalculateDamageContentsHousehold(obj, FloodDepth,FlowRate,RiseRate,ShelterFactor,Storm,CriticalFlowRate)
            if FloodDepth <= 0
                rs = 0;
            elseif FloodDepth >= 5
                rs = 1;
            elseif FlowRate > 0.25*CriticalFlowRate
                rs = 1;
            else
                if Storm ~=  0 %(s<>0){storm}
                    StormFactor = 0.8E-3 * FloodDepth^1.8 * ShelterFactor;
                else
                    StormFactor =  0;
                end
                if FloodDepth <= 1
                    s1 = -0.470 * FloodDepth^2 + 0.940*FloodDepth; % 0,1
                elseif FloodDepth <= 2
                    s1 = 0.030 * FloodDepth + 0.44; %1,2
                elseif FloodDepth <= 4
                    s1 = 0.005 * FloodDepth^2 + 0.135 * FloodDepth + 0.21; %2,4
                else
                    s1 = -0.170 * FloodDepth^2 + 1.700 * FloodDepth - 3.25; %4,5
                end
                rs = max([0,min([1, s1]) ]);
                rs = StormFactor * 1 + (1 - StormFactor) * rs;
            end
            DamageHouseholdContents = max([0, min([1, rs]) ]);
        end
        
        function DamageHouse = CalculateDamageHouse(obj, FloodDepth,FlowRate,w,ShelterFactor,Storm,CriticalFlowRate)
            if FloodDepth <= 0
                rs = 0;
            elseif FloodDepth >= 5
                rs = 1;
            elseif FlowRate > 0.25 * CriticalFlowRate
                rs = 1;
            else
                if  Storm ~= 0 %(s<>0){storm}
                    StormFactor =  0.8E-3 * FloodDepth^1.8 * ShelterFactor;
                else
                    StormFactor = 0;
                end
                if FloodDepth < 2
                    s1 = 0.005 * FloodDepth^2 + 0.045*FloodDepth; %0,2
                elseif FloodDepth<4
                    s1 = 0.045 * FloodDepth^2 + 0.015 * FloodDepth - 0.1; %2,4
                else
                    s1 = -0.32  * FloodDepth^2 + 3.2 *FloodDepth - 7;  %4,5
                end
                rs = max(0,min(1,s1));
                rs = StormFactor*1+(1-StormFactor)*rs;
            end
            DamageHouse = max([0, min([1, rs]) ]);
        end
    end
end