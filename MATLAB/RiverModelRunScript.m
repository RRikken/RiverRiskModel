%% Init workers for Parpool
% gcp;

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
% - Kolom 2: Gemiddelde stroomvoerende breedte zomerbed b1 (m)
% - Kolom 3: Gemiddelde bodemhoogte zomerbed z1 (m+NAP)
% - Kolom 4: Gemiddelde stroomvoerende breedte kribsectie+uiterwaard b2 (m)
% - Kolom 5: Gemiddelde bodemhoogte kribsectie+uiterwaard z2 (m+NAP)
% - Kolom 6: Gemiddeld verhang i (m/km)

RiverModel5_1 = River(DataForLocation5_1(2), DataForLocation5_1(4), 12.6, DataForLocation5_1(3), DataForLocation5_1(5), ...
    DataForLocation5_1(6)  * 10^-3, [0:50:14000], 2/3);
[ Pressure5_1, WaveRepeatTime5_1, WaterHeightSummerBed5_1, WaterHeightWinterBed5_1 ]  = RiverModel5_1.CalculatePressureAndWaterHeight(WaveLobith * (2/3));

RiverModel5_2 = River(DataForLocation5_2(2), DataForLocation5_2(4), 7.5, DataForLocation5_2(3), DataForLocation5_2(5), ...
    DataForLocation5_2(6) * 10^-3, [0:50:8000], 2/9);
[ Pressure5_2, WaveRepeatTime5_2, WaterHeightSummerBed5_2, WaterHeightWinterBed5_2 ]  = RiverModel5_2.CalculatePressureAndWaterHeight(WaveLobith * (2/9));

%% Initialize dike breach model
% TODO: add to script
BreachBottomHeight5_1 = 7.4;
BreachBottomHeight5_2 = 3.3;
BreachOuterWaterLevel5_1 = WaterHeightSummerBed5_1 - BreachBottomHeight5_1;
BreachOuterWaterLevel5_2 = WaterHeightSummerBed5_2 - BreachBottomHeight5_2;
DeltaH5_1 = 1.3;
DeltaH5_2 = 0.58;
BreachInsideWaterLevel5_1 = BreachOuterWaterLevel5_1 - DeltaH5_1;
BreachInsideWaterLevel5_2 = BreachOuterWaterLevel5_2 - DeltaH5_2;
FlowThroughBreach5_1 = CalculateFlowThroughBreach(DeltaH5_1, BreachInsideWaterLevel5_1);
FlowThroughBreach5_2 = CalculateFlowThroughBreach(DeltaH5_1, BreachInsideWaterLevel5_1);

FlowThroughBreach5_1(FlowThroughBreach5_1 < 0) = 0;
FlowThroughBreach5_2(FlowThroughBreach5_2 < 0) = 0;
%% Initialize dike ring area and damage model
DikeRingArea43 = DikeRingArea(43, landgebruik, ahn100_gem, ahn100_max, inwoners);
DamageModelOne = DamageModel;
%%
%[TypeOfLandUsage, MaximumDamage ] =  DamageModelOne.ChangeLandUsageToStandardModelTypes(DikeRingArea43.Landusage, MaximumDamageLookupTable);

[ Rows, Columns ] = size(FloodDepthMap);
FlowRate = zeros(Rows, Columns) + 1;
CriticalFlowRate = zeros(Rows, Columns) + 8; 
ShelterFactor = zeros(Rows, Columns);
Storm = 0;

DamageFactorsMap = DamageModelOne.SelectDamageFactors(TypeOfLandUsage, FloodDepthMap, FlowRate, CriticalFlowRate, ShelterFactor, Storm);

 NumberOfUnits = ones(Rows, Columns) .* (100 * 100);
 
[TotalDamage, DamageMap] = DamageModelOne.CalculateStandardDamageModel(DamageFactorsMap, MaximumDamage, NumberOfUnits);

