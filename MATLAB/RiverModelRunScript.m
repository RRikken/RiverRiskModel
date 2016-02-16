%% Set location variables
LocationNumber = 5.1;
HeightWinterDike = 12.6;
FlowTotal = [0:50:14000];
DivisionOfWaterFromLobith = (2/3);

BreachBottomHeight5_1 = 7.4;
BreachBottomHeight5_2 = 3.3;
WidthBreach = 300;
InsideHeightMeasuringLocation = [113, 584];
BreachBottomHeight = BreachBottomHeight5_1;

DikeBreachLocations5_1 = [118,583; 118,584;118,585;];
DikeBreachLocations5_2 = [9, 343; 9, 344; 9, 345];
DikeBreachLocations = DikeBreachLocations5_1;
AreaSize = 100 * 100;

%% Load all of the data files
Directory = 'Data\*.*';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 3 : NumberOfFileIds
    load(FileNames(K).name);
end
clear FileNames Directory K NumberOfFileIds Values

% parpool('local', 7)

%%  Initialize river model
% Select the data for the breachlocation
RiverData = RiverProfiles(RiverProfiles.Location == LocationNumber, : );

RiverModel = River(RiverData.WidthSummerBed, RiverData.WidthGroyneAndFloodplain, HeightWinterDike,...
    RiverData.BottomHeightSummerBed, RiverData.BottomHeightGroyneAndFloodplain, RiverData.Gradient,...
    FlowTotal, DivisionOfWaterFromLobith);

[ Pressure, WaveRepeatTime, WaterHeightSummerBed, WaterHeightWinterBed ]...
    = RiverModel.CalculatePressureAndWaterHeight( WaveLobith );

%% Initialize dike breach model
BreachFlow = BreachFlowModel(WidthBreach, BreachBottomHeight, InsideHeightMeasuringLocation);

%% Set variables needed

[ Rows, Columns ] = size(ahn100_max);
WaterContentMap = zeros(Rows, Columns);
[ WaterContents3dMap ] = CalculateWaterDepthAndFlowRate(AreaSize, WaterContentMap, DikeBreachLocations, WaterHeightWinterBed, BreachFlow, ahn100_max);

save('ModelOutput\Results5_1.mat','WaterDepth3dMap', 'WaterContents3dMap')
%%
% Initialize dike ring area and damage model

WaterRiseRateMapMax = max(WaterRiseRateMap, [], 3, 'omitnan');
%calculate damages
ahn100_gem = ahn100_max;
DikeRingArea43 = DikeRingArea(43, landgebruik, ahn100_gem, ahn100_max, inwoners);
DamageModelOne = DamageModel;
[TypeOfLandUsage, MaximumDamage ] =  DamageModelOne.ChangeLandUsageToStandardModelTypes(DikeRingArea43.Landusage, MaximumDamageLookupTable);

[ Rows, Columns ] = size(ahn100_max);
TotalDamageMap = zeros(Rows, Columns, Pages);
CasualtyMap = zeros(Rows, Columns, Pages);
FlowRate = zeros(Rows, Columns) + 1;
CriticalFlowRate = zeros(Rows, Columns) + 8;
ShelterFactor = zeros(Rows, Columns);
Storm = 0;
FlowRateMapTemp = WaterRiseRateMap;
NumberOfUnits = ones(Rows, Columns) .* (200 * 200);

for Page = 1 : Pages
    %Calculate damage
    DamageFactorsMap = DamageModelOne.SelectDamageFactors(TypeOfLandUsage, FloodDepthMapTemp(:,:,Page), FlowRateMapTemp(:,:,Page), CriticalFlowRate, ShelterFactor, Storm);
    [ TotalDamageMap(:,:,Page) ] = DamageModelOne.CalculateStandardDamageModel( DamageFactorsMap, MaximumDamage, NumberOfUnits);

    % Calculate casualties
    CasualtyMap(:,:,Page) = DamageModelOne.CalculateCasualties(FloodDepthMapTemp(:,:,Page), FlowRateMapTemp(:,:,Page), WaterRiseRateMap(:,:,Page), inwoners);
    DikeRingArea43.PlotArea( CasualtyMap(:,:,Page));
    
end