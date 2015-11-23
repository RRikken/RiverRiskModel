%Load all of the data files
Directory = 'Data\*.*';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 3:NumberOfFileIds
    load(FileNames(K).name);
end
clear FileNames Directory K NumberOfFileIds Values

[ Rows, Columns, Pages ] = size(WaterDepth3dMap);
FloodDepthMap = zeros(223,983, Pages);
FlowRateMap = zeros(223,983, Pages);
WaterRiseRateMap = zeros(223,983, Pages);
WaterContentsMap = zeros(223,983, Pages);
for Page = 1 : Pages
    for Row = 1 : Rows
        for Column =  1 : Columns
            RowOne = Row * 2-1;
            RowTwo = Row * 2;
            ColumnOne = Column * 2 - 1;
            ColumnTwo = Column * 2;
            FloodDepthMap(RowOne:RowTwo, ColumnOne:ColumnTwo, Page) = WaterDepth3dMap(Row,Column, Page);
            WaterContentsMap(RowOne:RowTwo, ColumnOne:ColumnTwo, Page) = WaterContents3dMap(Row,Column, Page);
            if (Page + 5) >= Pages
                WaterRiseRateMap(RowOne:RowTwo,ColumnOne:ColumnTwo,Page) = WaterRiseRateMap(Row,Column,Page - 1);
            else
                WaterRiseRateMap(RowOne:RowTwo,ColumnOne:ColumnTwo,Page) = (WaterDepth3dMap(Row,Column, Page + 6) -WaterDepth3dMap(Row,Column, Page)); % Multiply to convert to meters per hour
            end
        end
    end
end

FlowRateMap = WaterRiseRateMap;

save('ModelOutput\RiseRateAndFlowRateMap5_2.mat','WaterRiseRateMap', 'FlowRateMap','FloodDepthMap', 'WaterContentsMap' )

WaterRiseRateMapMax = max(WaterRiseRateMap, [], 3, 'omitnan');
calculate damages

DikeRingArea43 = DikeRingArea(43, landgebruik, ahn100_gem, ahn100_max, inwoners);
DamageModelOne = DamageModel;
% [TypeOfLandUsage, MaximumDamage ] =  DamageModelOne.ChangeLandUsageToStandardModelTypes(DikeRingArea43.Landusage, MaximumDamageLookupTable);

[ Rows, Columns, Pages ] = size(WaterRiseRateMap);
TotalDamageMap = zeros(Rows, Columns, Pages);
CasualtyMap = zeros(Rows, Columns, Pages);
FlowRate = zeros(Rows, Columns) + 1;
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

    WaterRiseRateMapMax( WaterRiseRateMap(:,:,Page + 1) > WaterRiseRateMapMax) = 0 ;
    WaterRiseRateMapMaxBiggerValues = WaterRiseRateMap(:,:,Page + 1);
    WaterRiseRateMapMaxBiggerValues( WaterRiseRateMapMaxBiggerValues <= WaterRiseRateMapMax) = 0 ;
    WaterRiseRateMapMax = WaterRiseRateMapMax + WaterRiseRateMapMaxBiggerValues;
    
    FlowRateMapMax = WaterRiseRateMapMax * 2;
end

