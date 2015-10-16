%lokatie 5.1 (Waal)

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

profiel_1_2 = Profielen_tabel(11,:) % Locatie 1.2 is eerste rij in bestand van profielen
b1_1_2 = profiel_1_2(2) % Breedte zomerbed is tweede kolom in tabel (zie uitleg hierboven)
h_max = 10; % Bepaal zelf een maximale waterhoogte of debiet

%% Figuur plotten
x = [0,0,profiel_1_2(2),profiel_1_2(2),(profiel_1_2(2)+profiel_1_2(4)),(profiel_1_2(2)+profiel_1_2(4))];
y = [h_max,profiel_1_2(3),profiel_1_2(3),profiel_1_2(5),profiel_1_2(5),h_max];
plot(x,y,'LineWidth',3)
axis([-100 800 -6 10])
xlabel('x (m)')
ylabel('Bodemhoogte (m+NAP)')
title('Rivierprofiel locatie 5.1')

% data rivier etc
breedte_zomerbed = 255;          % in meters
breedte_winterbed = 970;         % in meters
breedte_totaal = 1225;           % in meters  = breedte_zomerbed+breedte_winterbed
hoogte_winterdijk = 12.91;       % m+NAP
bodemhoogte_winterbed = 6.85;    % m+NAP
bodemhoogte_zomerbed = 0.00;     % m+NAP
verhang = 0.18*10.^-3;           % m/m
Cf = 0.005;                      % chezy waarde zomerbed en winterbed. aangenomen dat ze gelijk zijn!
grav = 9.81;                     % gravitatie constante in m/s2
P_atm = 10^5;                    % atmosferische druk in N/m2
Rho = 1000;                      % dichtheid water in kg/m3

%Afvoerverdeling via verschillende rijntakken
Q_Lobith = [0:50:21000];                                                    % in m3/s
k = 1./3;                                                                   %1/3 van de Rijn stroomt naar de Waal
%Omzetten bodemhoogtes naar diepte
diepte_zomerbed = bodemhoogte_winterbed-bodemhoogte_zomerbed;
diepte_winterbed = hoogte_winterdijk-bodemhoogte_winterbed;

%maximale afvoeren
Qmax_zomerbed = (breedte_zomerbed.*(diepte_zomerbed).^1.5).*sqrt((grav.*verhang)./Cf);
Qmax_winterbed_zomerbed = (breedte_totaal.*(diepte_winterbed).^1.5).*sqrt((grav.*verhang)./Cf); 
Qmax = Qmax_zomerbed + Qmax_winterbed_zomerbed;

%waterhoogte berekening
waterhoogte_zomerbed = (Q_Lobith./(breedte_zomerbed.*sqrt(grav./Cf).*sqrt(verhang))).^(2./3);      
waterhoogte_winterbed= ((Q_Lobith-Qmax_zomerbed)./(breedte_totaal.*sqrt(grav./Cf).*sqrt(verhang))).^(2./3);

%Nulvectoren gemaakt
hoogte_zomerbed = zeros(1,500);
hoogte_winterbed = zeros(1,500);
P = zeros(1,500);

%Constanten voor bepaling terugkeertijd in jaren bepaalde afvoer
a = 1316.4;                                                                 %komt uit TRontwerp pag.76-77 (2001)
c = 6612.6;

%Model

for i = 1:length(Q_Lobith)
    
if Q_Lobith(i) <= Qmax_zomerbed
    hoogte_zomerbed(i) = bodemhoogte_zomerbed + waterhoogte_zomerbed(i);
elseif Q_Lobith(i) >= Qmax_zomerbed
    hoogte_winterbed(i) = bodemhoogte_winterbed + waterhoogte_winterbed(i);
end

if Q_Lobith(i) > Qmax
    hoogte_winterbed(i) = hoogte_winterdijk;
end

if hoogte_winterbed(i) >= bodemhoogte_winterbed
    P(i) = P_atm + Rho*grav*(hoogte_winterbed(i)-bodemhoogte_winterbed); 
else
    P(i) = P_atm;
end
T(i) = exp((Q_Lobith(i)-k.*c)./(k.*a));                                     
end


%data naar excel sturen
xlswrite('locatie5_1.xlsx', Q_Lobith', 'output', 'a2')
xlswrite('locatie5_1.xlsx', hoogte_zomerbed', 'output', 'b2')
xlswrite('locatie5_1.xlsx', hoogte_winterbed', 'output', 'c2')
xlswrite('locatie5_1.xlsx', P', 'output', 'd2')
xlswrite('locatie5_1.xlsx', T', 'output', 'e2')