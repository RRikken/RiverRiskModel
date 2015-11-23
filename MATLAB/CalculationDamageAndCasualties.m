%Load all of the data files
Directory = 'Data\*.*';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 3:NumberOfFileIds
    load(FileNames(K).name);
end
clear FileNames Directory K NumberOfFileIds Values

%% calculate damages

DikeRingArea43 = DikeRingArea(43, landgebruik, ahn100_gem, ahn100_max, inwoners);
DamageModelOne = DamageModel;
% [TypeOfLandUsage, MaximumDamage ] =  DamageModelOne.ChangeLandUsageToStandardModelTypes(DikeRingArea43.Landusage, MaximumDamageLookupTable);

[ Rows, Columns, Pages ] = size(WaterRiseRateMap);
TotalDamageMap = zeros(Rows, Columns, Pages);
CasualtyMap = zeros(Rows, Columns, Pages);

CriticalFlowRate = zeros(Rows, Columns) + 8;
ShelterFactor = zeros(Rows, Columns);
Storm = 0;
NumberOfUnits = ones(Rows, Columns) .* (200 * 200);

WaterRiseRateMapMax = WaterRiseRateMap(:,:,1);
FlowRateMapMax = WaterRiseRateMapMax;

for Page = 1 : Pages
    %Calculate damage
    DamageFactorsMap = DamageModelOne.SelectDamageFactors(TypeOfLandUsage, FloodDepthMap(:,:,Page), FlowRateMapMax, CriticalFlowRate, ShelterFactor, Storm);
    [ TotalDamageMap(:,:,Page) ] = DamageModelOne.CalculateStandardDamageModel( DamageFactorsMap, MaximumDamage, NumberOfUnits);

    % Calculate casualties
    CasualtyMap(:,:,Page) = DamageModelOne.CalculateCasualties(FloodDepthMap(:,:,Page), FlowRateMapMax, WaterRiseRateMapMax, inwoners);
if Page + 1 <= Pages
    WaterRiseRateMapMax( WaterRiseRateMap(:,:,Page + 1) > WaterRiseRateMapMax) = 0 ;
    WaterRiseRateMapMaxBiggerValues = WaterRiseRateMap(:,:,Page + 1);
    WaterRiseRateMapMaxBiggerValues( WaterRiseRateMapMaxBiggerValues <= WaterRiseRateMapMax) = 0 ;
    WaterRiseRateMapMax = WaterRiseRateMapMax + WaterRiseRateMapMaxBiggerValues;
    
    FlowRateMapMax = WaterRiseRateMapMax * 2;
end
end

save('ModelOutput\CasualtiesAndDamage5_2.mat','CasualtyMap', 'TotalDamageMap' )