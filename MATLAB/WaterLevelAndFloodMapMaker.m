
% Initialize dike ring area and damage model
% Expand map
load('Results5_2_120000_StepsOf6')
[ Rows, Columns, Pages ] = size(WaterContents3dMap);
FloodDepthMapTemp = zeros(223,983, Pages);
WaterRiseRateMap = zeros(223,983, Pages);
WaterContentsMap = zeros(223,983, Pages);
WaterLevelMap = WaterContents3dMap ./ (200 * 200);
FloodDepthMap = zeros(223,983, Pages);

for Page = 1 : Pages
    for Row = 1 : Rows
        for Column =  1 : Columns
            RowOne = Row * 2-1;
            RowTwo = Row * 2;
            ColumnOne = Column * 2 - 1;
            ColumnTwo = Column * 2;
            FloodDepthMap(RowOne:RowTwo, ColumnOne:ColumnTwo, Page) = WaterLevelMap(Row, Column, Page);
            WaterContentsMap(RowOne:RowTwo, ColumnOne:ColumnTwo, Page) = WaterContents3Map(Row,Column, Page);
            if Page + 1 < Pages
                WaterRiseRateMap(RowOne:RowTwo,ColumnOne:ColumnTwo,Page) = FloodDepthMapTemp(Row,Column,Page + 1) - FloodDepthMapTemp(Row,Column,Page);
            end
        end
    end
end
%%
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