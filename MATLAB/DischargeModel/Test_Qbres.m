function FlowThroughBreach = CalculateFlowThroughBreach()
%data
gravitation = 9.81;
WidthBres = 300;
%Formules
FlowThroughBreach = ((2*gravitation)^0.5)*WidthBres*DeltaH1*HeightBresIn1;
end