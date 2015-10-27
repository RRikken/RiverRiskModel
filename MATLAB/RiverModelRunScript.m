%% Load all of the data files
Directory = 'Data\*.*';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 3:NumberOfFileIds
    load(FileNames(K).name);
end
clear FileNames Directory K NumberOfFileIds Values

%%  Initialize river model
% Select the data for the breachlocations
% TODO: Put data into MATLAB table for better readability
ProfileDataRow5_1 = ( Profielen(:,1) == 5.1);
DataForLocation5_1 = Profielen(ProfileDataRow5_1,:);

ProfileDataRow5_2 = ( Profielen(:,1) == 5.2);
DataForLocation5_2 = Profielen(ProfileDataRow5_2,:);

clear ProfileDataRow5_2 ProfileDataRow5_1

% - Kolom 2: Gemiddelde stroomvoerende breedte zomerbed b1 (m)
% - Kolom 3: Gemiddelde bodemhoogte zomerbed z1 (m+NAP)
% - Kolom 4: Gemiddelde stroomvoerende breedte kribsectie+uiterwaard b2 (m)
% - Kolom 5: Gemiddelde bodemhoogte kribsectie+uiterwaard z2 (m+NAP)
% - Kolom 6: Gemiddeld verhang i (m/km)

RiverModel5_1 = River(DataForLocation5_1(2), DataForLocation5_1(4), 12.6, DataForLocation5_1(3), DataForLocation5_1(5), ...
    DataForLocation5_1(6), [0:50:14000]);

RiverModel5_2 = River(DataForLocation5_2(2), DataForLocation5_2(4), 7.5, DataForLocation5_2(3), DataForLocation5_2(5), ...
    DataForLocation5_2(6), [0:50:8000]);

%% Initialize dike breach model
% TODO: add to script

%% Initialize dike ring area and damage model
DikeRingArea43 = DikeRingArea(43, landgebruik, ahn100_gem, ahn100_max, inwoners);
DamageModelOne = DamageModel;

%% Calculate model results
[ Pressure5_1, WaterHeightSummerBed5_1, WaterHeightWinterBed5_1 ] = RiverModel5_1.CalculatePressureAndWaterHeight;
[ Pressure5_2, WaterHeightSummerBed5_2, WaterHeightWinterBed5_2 ] = RiverModel5_2.CalculatePressureAndWaterHeight;

%[TypeOfLandUsage, MaximumDamage ] =  DamageModelOne.ChangeLandUsageToStandardModelTypes(DikeRingArea43.Landusage, MaximumDamageLookupTable);

FloodDepthMap = DikeRingArea43.CalculateFloodDepth(6);
% DikeRingArea43.PlotArea(FloodDepthMap);

[ Rows, Columns ] = size(FloodDepthMap);
FlowRate = zeros(Rows, Columns) + 1;
CriticalFlowRate = zeros(Rows, Columns) + 8;
ShelterFactor = zeros(Rows, Columns);
Storm = 0;
%% 
DikeBreachLocations = [118, 583; 118, 584; 118, 585];
UniqueIDs = [118583; 118584;118585;];
UpdateList =  [DikeBreachLocations UniqueIDs];
AreaSize = 100 * 100;
BreachFlow = zeros(1, 100) + 4000;
[ AreaMapStructure, WaterContentMap ] = BuildStructureForArea( ahn100_max, AreaSize );

for TimeStep = 1 : length(BreachFlow) 
    for ind = 1 : length(DikeBreachLocations(:,1))
        Row = DikeBreachLocations(ind, 1);
        Column = DikeBreachLocations(ind, 2);
        WaterContentMap(Row, Column) = BreachFlow(TimeStep);
        AreaMapStructure(Row, Column).WaterLevel = WaterContentMap(Row, Column) / AreaMapStructure(Row, Column).AreaSize + AreaMapStructure(Row, Column).BottomHeight;
        AreaMapStructure(Row, Column).WaterDepth = WaterContentMap(Row, Column) / AreaMapStructure(Row, Column).AreaSize;
        AreaMapStructure(Row, Column).InFlow(4,2) = 1;
    end
    
    for ind2 = 1 : length(UpdateList(:,1))
        [ WaterOutflowVolumes, NewUpdateListItems ] = CalculateOutFlows(  AreaMapStructure, WaterContentMap, UpdateList( ind2, 1 ), UpdateList( ind2, 2 ), UpdateList );
        AreaMapStructure( UpdateList( ind2, 1 ), UpdateList( ind2, 2 ) ).OutFlow = WaterOutflowVolumes;
    end
    
    for  ind3 = 1 : length(UpdateList(:,1))
        [ AreaMapStructure, WaterContentMap ] = PutOutflowIntoArea( AreaMapStructure, WaterContentMap, UpdateList( ind3, 1 ), UpdateList( ind3, 2 ) );
        AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).WaterLevel = ...
            WaterContentMap(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )) / AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).AreaSize...
            + AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).BottomHeight;
        AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).WaterDepth =...
            WaterContentMap(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )) / AreaMapStructure(UpdateList( ind3, 1 ), UpdateList( ind3, 2 )).AreaSize;
    end
    UpdateList = [UpdateList; NewUpdateListItems];
end

%%
% DamageFactorsMap = DamageModelOne.SelectDamageFactors(TypeOfLandUsage, FloodDepthMap, FlowRate, CriticalFlowRate, ShelterFactor, Storm);
%

% DikeRingArea43.PlotArea(WaterHeightMap);
% NumberOfUnits = ones(Rows, Columns) .* (100 * 100);
%
% [TotalDamage, DamageMap] = DamageModelOne.CalculateStandardDamageModel(DamageFactorsMap, MaximumDamage, NumberOfUnits);
%%
% Z = HeightMaps(:,:,1);
% surf(Z)
% axis tight manual
% ax = gca;
% ax.NextPlot = 'replaceChildren';
% 
% loops = 100;
% F(loops) = struct('cdata',[],'colormap',[]);
% for j = 1:loops
%     
%     surf(HeightMaps(:,:,j))
%     drawnow
%     F(j) = getframe(gcf);
% end
