profile on
%% Load all of the data files
Directory = 'Data\*.*';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 3:NumberOfFileIds
    load(FileNames(K).name);
end
clear FileNames Directory K NumberOfFileIds Values

% LargeAreaAHN400_max = zeros(222 / 2, 982 / 2);
% for Row = 1 : 222 / 2
%     for Column =  1 : 982 / 2
%         RowOne = Row * 2-1;
%         RowTwo = Row * 2;
%         ColumnOne = Column * 2 - 1;
%         ColumnTwo = Column * 2;
%         MaxFromArea  = max(max(ahn100_max( RowOne : RowTwo, ColumnOne : ColumnTwo)));
%         LargeAreaAHN400_max(Row, Column) = MaxFromArea;
%     end
% end
% 
% clear Row Column RowOne RowTwo ColumnOne ColumnTwo MaxFromArea

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
% TODO: move static numbers to file
BreachBottomHeight5_1 = 7.4;
BreachBottomHeight5_2 = 3.3;
WidthBreach5_1 = 300;
WidthBreach5_2 = 300;
InsideHeightMeasuringLocation5_1 = [116, 584];
InsideHeightMeasuringLocation5_2 = [];
BreachFlow5_1 = BreachFlowModel(WidthBreach5_1, BreachBottomHeight5_1, InsideHeightMeasuringLocation5_1);
BreachFlow5_2 = BreachFlowModel(WidthBreach5_2, BreachBottomHeight5_2, InsideHeightMeasuringLocation5_2);

%% Set variables needed
DikeBreachLocations5_1 =[118,583; 118,584;118,585;];
% DikeBreachLocations5_2 = [9, 343; 9, 344; 9, 345];
% DikeBreachLocations5_2 = [6, 172; 6, 173];
BreachInFlowLogicalRowNumber = 4;
UniqueIDs = [118583; 118584;118585;];
% UniqueIDs = [59291; 59292; ];
% UniqueIDs = [6172; 6173; ];
AreaSize = 100 * 100;

FloodedCellsMap = containers.Map(118583,[118, 583]);
FloodedCellsMap(118584) = [118, 584];
FloodedCellsMap(118585) = [118, 585];

WaterHeightWinterBed5_1 = zeros(1,100) + 11;

[ AreaMapStructure, WaterContentMap, WaterLevelMap ] = BuildStructureForArea( ahn100_max );
[  WaterDepth3dMap, WaterContents3dMap ] = CalculateWaterDepthAndFlowRate(AreaSize, AreaMapStructure, WaterContentMap, WaterLevelMap, FloodedCellsMap, DikeBreachLocations5_1, BreachInFlowLogicalRowNumber, WaterHeightWinterBed5_1, BreachFlow5_1);

save('ModelOutput\Results5_1.mat','WaterDepth3dMap', 'WaterContents3dMap')
% Initialize dike ring area and damage model
% Expand map
[ Rows, Columns, Pages ] = size(WaterDepth3dMap);
FloodDepthMapTemp = zeros(223,983, Pages);
FlowRateMapTemp = zeros(223,983, Pages);
WaterRiseRateMap = zeros(223,983, Pages);
WaterContentsMap = zeros(223,983, Pages);
for Page = 1 : Pages
    for Row = 1 : Rows
        for Column =  1 : Columns
            RowOne = Row * 2-1;
            RowTwo = Row * 2;
            ColumnOne = Column * 2 - 1;
            ColumnTwo = Column * 2;
            FloodDepthMapTemp(RowOne:RowTwo, ColumnOne:ColumnTwo, Page) = WaterDepth3dMap(Row,Column, Page);
            WaterContentsMap(RowOne:RowTwo, ColumnOne:ColumnTwo, Page) = WaterContents3dMap(Row,Column, Page);
            if (Page + 5) >= Pages
                WaterRiseRateMap(RowOne:RowTwo,ColumnOne:ColumnTwo,Page) = WaterRiseRateMap(Row,Column,Page - 1);
            else
                WaterRiseRateMap(RowOne:RowTwo,ColumnOne:ColumnTwo,Page) = (WaterDepth3dMap(Row,Column, Page + 6) -WaterDepth3dMap(Row,Column, Page)); % Multiply to convert to meters per hour
            end
        end
    end
end

WaterRiseRateMapMax = max(WaterRiseRateMap, [], 3, 'omitnan');
%calculate damages
ahn100_gem = ahn100_max;
DikeRingArea43 = DikeRingArea(43, landgebruik, ahn100_gem, ahn100_max, inwoners);
DamageModelOne = DamageModel;
% [TypeOfLandUsage, MaximumDamage ] =  DamageModelOne.ChangeLandUsageToStandardModelTypes(DikeRingArea43.Landusage, MaximumDamageLookupTable);

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
%     DikeRingArea43.PlotArea( CasualtyMap(:,:,Page));
    
end

profile off
% profsave(profile('info'),'ProfilerResults\60Steps')