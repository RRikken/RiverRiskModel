function FlowThroughBreach = CalculateFlowThroughBreach(HeightDifference, HeightBreachInside)
%data
Gravitation = 9.81;
WidthBreach = 300;
%Formules
FlowThroughBreach = ((2 * Gravitation)^0.5) * WidthBreach * HeightDifference^(0.5) * HeightBreachInside;
end