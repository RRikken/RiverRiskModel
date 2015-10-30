clear,clc

%Data
ThicknessSandLayer = 25;
SeepageLength1 = 63.22;
SeepageLength2 = 45.71;
WeightWater = 1000;
WeightGrain = 2000;
RollResistanceAngle = 41*(pi/180);
TowForceFactor = 0.25;
PercentileSand = 0.0007500;
DoorlatendheidGrofZand = 1.16e-4;
GravitatieConstante = 9.81;
ViscositeitGrondwater = 1.32*10^-6;
HeightGroundLevel = 1;


%Tussen formules
%Gebruikt voor beide
VolumeGewichtGrondOnderWater = WeightGrain-WeightWater;
IntrinsiekePermeabiliteit = (ViscositeitGrondwater/GravitatieConstante)*DoorlatendheidGrofZand;
%5.1
Alpha = (ThicknessSandLayer/SeepageLength1)^(0.28/(((ThicknessSandLayer/SeepageLength1)^2.8)-1));
ConstanteC = TowForceFactor*(PercentileSand/((IntrinsiekePermeabiliteit*SeepageLength1)^(1/3)));
%5.2
Alpha = (ThicknessSandLayer/SeepageLength2)^(0.28/(((ThicknessSandLayer/SeepageLength2)^2.8)-1));
ConstanteC = TowForceFactor*(PercentileSand/((IntrinsiekePermeabiliteit*SeepageLength2)^(1/3)));

%Berekening Piping
KritiekeVerval = Alpha*ConstanteC*(VolumeGewichtGrondOnderWater/WeightWater)*tan(RollResistanceAngle)*(0.68-0.10*log(ConstanteC))*SeepageLength1  %locatie 5.1
KritiekeVerval = Alpha*ConstanteC*(VolumeGewichtGrondOnderWater/WeightWater)*tan(RollResistanceAngle)*(0.68-0.10*log(ConstanteC))*SeepageLength2  %locatie 5.2
