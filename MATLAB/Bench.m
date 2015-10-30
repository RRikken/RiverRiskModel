%% Load all of the data files
Directory = 'Data\*.*';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 3:NumberOfFileIds
    load(FileNames(K).name);
end
clear FileNames Directory K NumberOfFileIds Values

%%
DikeBreachLocations = [118, 583; 118, 584; 118, 585];
UniqueIDs = [118583; 118584;118585;];
AreaSize = 100 * 100;
BreachFlow = zeros(1,100) + 1000;


WaterContainerMap = FloodedAreaCalc( DikeBreachLocations, UniqueIDs, BreachFlow, ahn100_gem, AreaSize );