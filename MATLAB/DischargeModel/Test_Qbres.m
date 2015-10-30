clear,clc

%data
gravitation = 9.81;
WidthBres = 300;
DeltaH1 = 1.3;
DeltaH2 = 0.58;
HeightBresIn1 = 11.61;
HeightBresIn2 = 8.58;
HeightBresOut1 = 6.06;
HeightBresOut2 = 4.85;
%Formules
FlowBres1 = ((2*gravitation)^0.5)*WidthBres*DeltaH1*HeightBresIn1

FlowBres2 = ((2*gravitation)^0.5)*WidthBres*DeltaH2*HeightBresIn2

opgave = (2/3)^1.5 * 9.81^0.5 * 300 * 4.85^1.5;

%ongestuwde- of gestuwde instroom

if HeightBresIn1 < (2/3)*HeightBresOut1;
    disp(1)
else HeightBresIn1 > (2/3)*HeightBresOut1;
    disp(2)
end

if HeightBresIn2 < (2/3)*HeightBresOut2;
    disp(1)
else HeightBresIn2 > (2/3)*HeightBresOut2;
    disp(2)
end