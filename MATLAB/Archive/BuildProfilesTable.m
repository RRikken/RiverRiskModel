%% Data:
% - Kolom 1: Locatie van het profiel in de rivier
% - Kolom 2: Gemiddelde stroomvoerende breedte zomerbed b1 (m)
% - Kolom 3: Gemiddelde bodemhoogte zomerbed z1 (m+NAP)
% - Kolom 4: Gemiddelde stroomvoerende breedte kribsectie+uiterwaard b2 (m)
% - Kolom 5: Gemiddelde bodemhoogte kribsectie+uiterwaard z2 (m+NAP)
% - Kolom 6: Gemiddeld verhang i (m/km)
%% Construct the table
ProfileTextData = importdata('Profielen.txt');
RiverProfiles = table(ProfileTextData(:,1), ProfileTextData(:,2),...
    ProfileTextData(:,3), ProfileTextData(:,4), ProfileTextData(:,5),...
    ProfileTextData(:,6),'VariableNames', {'Location', 'WidthSummerBed',... 
    'BottomHeightSummerBed', 'WidthGroyneAndFloodplain', ...
    'BottomHeightGroyneAndFloodplain', 'Gradient'});
RiverProfiles.Properties.VariableUnits = {'', 'm', 'm +NAP', 'm', 'm +NAP', 'm/km'};

save('Data\RiverProfiles.mat', 'RiverProfiles')