%% Load all of the data files
Directory = 'Data\*.txt';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 1:NumberOfFileIds
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

% TODO: Needs cleanup into a constructor
RiverModel5_1 = River;
RiverModel5_1.WidthSummerBed = DataForLocation5_1(2);
RiverModel5_1.WidthWinterBed  = DataForLocation5_1(4);
RiverModel5_1.HeightWinterDike  = 12.6; 
RiverModel5_1.BottomHeightSummerBed = DataForLocation5_1(3);
RiverModel5_1.BottomHeightWinterBed = DataForLocation5_1(5);
RiverModel5_1.Gradient = DataForLocation5_1(6);
RiverModel5_1.FlowTotal = [0:50:14000];

RiverModel5_2 = River;
RiverModel5_2.WidthSummerBed = DataForLocation5_2(2); 
RiverModel5_2.WidthWinterBed  = DataForLocation5_2(4); 
RiverModel5_2.HeightWinterDike  = 7.5;
RiverModel5_2.BottomHeightSummerBed = DataForLocation5_2(3); 
RiverModel5_2.BottomHeightWinterBed = DataForLocation5_2(5); 
RiverModel5_2.Gradient = DataForLocation5_2(6);
RiverModel5_2.FlowTotal = [0:50:8000];
%% Initialize dike breach model
% TODO: add to script

%% Initialize dike ring area and damage model
DikeRingArea43 = DikeRingArea;
% Needs cleanup into constructor
DikeRingArea43.Number = 43;
DikeRingArea43.Landusage = landgebruik;
DikeRingArea43.AverageHeightMap = ahn100_gem;
DikeRingArea43.MaximumHeightMap = ahn100_max;
DikeRingArea43.Inhabitants = inwoners;

%% Calculate model results
[ Pressure, HeightSummerBed, HeightWinterBed ] = RiverModel5_1.CalculatePressureAndWaterHeight;