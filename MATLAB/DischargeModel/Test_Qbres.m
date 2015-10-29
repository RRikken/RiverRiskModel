clear,clc

%data
gravitation = 9.81;
WidthBres = 300;
DeltaH1 = 1.3;
DeltaH2 = 3.05;
HeightBresIn1 = 11.61;
HeightBresIn2 = 8.58;

%Formules
FlowBres1 = ((2*gravitation)^0.5)*WidthBres*DeltaH1*HeightBresIn1

FlowBres2 = ((2*gravitation)^0.5)*WidthBres*DeltaH2*HeightBresIn2
