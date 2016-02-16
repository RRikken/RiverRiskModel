% Data en figuur Project Waterveiligheid module 5
% 
% Data:
% - dijkringgebieden: dijkringgebied 16 en dijkringgebied 43 in een
%   raster van 100*100 m (in matrixvorm). 
% - landgebruik: raster van 100*100 m (in matrixvorm), cel heeft waarde van 
%   dominante landgebruik. Bronnen: BBG2008 (CBS) en BRP2009 (Ministerie
%   van Economische Zaken)
%   Landgebruik-klassen:
%       1. Infrastructuur
%       2. Wonen
%       3. Handel en industrie
%       4. Instelling
%       5. Recreatie
%       6. Kassen
%       7. Grassen
%       8. Maïs
%       9. Aardappelen
%       10. Bieten
%       11. Granen
%       12. Boomkwekerijen
%       13. Fruitkwekerijen
%       14. Overig agrarisch terrein
%       15. Water
%       16. Natuur
% - inwoners: aantal inwoners per cel van 100*100 m (in matrixvorm). 
%   Bron: CBS (2013)
% - AHN_max: Actueel Hoogtebestand Nederland (AHN) raster van 5*5 m 
%   geaggregeerd naar cellen van 100*100 m (in matrixvorm). Waarde in 
%   AHN_max is de maximale hoogte in de 100*100 m.
% - AHN_gem: Waarde in de cel is de gemiddelde hoogte in de 100*100 m. 
%
% Figuur: x-as en y-as weergegeven voor 100 m (breedte cel). 

%% Inladen data
dijkringgebieden = load('dijkringgebieden.txt');
landgebruik = load('landgebruik.txt'); 
inwoners = load('inwoners.txt');
AHN_max = load('ahn100_max.txt');
AHN_gem = load('ahn100_gem.txt');
[n_Y,n_X] = size(landgebruik);

%% Figuur plotten
surf([1:n_X],[1:n_Y],flipud(AHN_gem),'EdgeColor','none'); view(2); colorbar; axis equal;
axis([0 1000 -100 300])
xlabel('x (100 m)')
ylabel('y (100 m)')
title('Dijkringgebieden')