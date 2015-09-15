% Profielen Project Waterveiligheid module 5
% 
% Data:
% - Kolom 1: Locatie van het profiel in de rivier
% - Kolom 2: Gemiddelde stroomvoerende breedte zomerbed b1 (m)
% - Kolom 3: Gemiddelde bodemhoogte zomerbed z1 (m+NAP)
% - Kolom 4: Gemiddelde stroomvoerende breedte kribsectie+uiterwaard b2 (m)
% - Kolom 5: Gemiddelde bodemhoogte kribsectie+uiterwaard z2 (m+NAP)
% - Kolom 6: Gemiddeld verhang i (m/km)
%
% De profielen zijn gemiddelde profielen over een traject van 5 km voor de
% locatie tot en met 5 km na de locatie. De gemiddelde profielen zijn
% bepaald op basis van profielgegevens uit het Rijntakkenmodel uit de 2000
% schematisatie van RIZA, waarin profielen in de Rijntakken beschreven 
% staan op elke 0,5 km. 
% De profielen zijn een grove schematisatie om te kunnen functioneren in 
% een uniform stationaire situatie.

clear, clc
%% Inladen data
Profielen_tabel = load('Profielen.txt');

profiel_1_2 = Profielen_tabel(1,:) % Locatie 1.2 is eerste rij in bestand van profielen
b1_1_2 = profiel_1_2(2) % Breedte zomerbed is tweede kolom in tabel (zie uitleg hierboven)
h_max = 10; % Bepaal zelf een maximale waterhoogte of debiet

%% Figuur plotten
x = [0,0,profiel_1_2(2),profiel_1_2(2),(profiel_1_2(2)+profiel_1_2(4)),(profiel_1_2(2)+profiel_1_2(4))];
y = [h_max,profiel_1_2(3),profiel_1_2(3),profiel_1_2(5),profiel_1_2(5),h_max];
plot(x,y,'LineWidth',3)
axis([-100 800 -6 10])
xlabel('x (m)')
ylabel('Bodemhoogte (m+NAP)')
title('Rivierprofiel locatie 1.2')