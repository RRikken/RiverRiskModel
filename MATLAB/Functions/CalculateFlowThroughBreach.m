function FlowThroughBreach = CalculateFlowThroughBreach(WidthBreach, HeightBreach, WaterLevelRiver, WaterLevelDikeRingArea)
% Debietformule (Visser, 1998; Ren, 2012)
% Qbres = 	(?)^1,5 ? g^0,5 ? Bbres ? hbr_uit^1,5	als hbr_in  < ? ? hbr_uit	ongestuwde instroom
% Qbres = 	(2?g)^0,5 ? Bbres ?  ?h^0,5? hbr_in als hbr_in  > ? ? hbr_uit	gestuwde instroom

WaterLevelDifference = WaterLevelRiver - WaterLevelDikeRingArea;
WaterLevelInsideBreach = HeightBreach - WaterLevelDikeRingArea;
WaterLevelOusideBreach = HeightBreach - WaterLevelRiver;

Gravity = 9.81;

    if WaterLevelInsideBreach < (2/3) * WaterLevelOusideBreach
        FlowThroughBreach = (2/3)^(1.5) * Gravity^(0.5) * WidthBreach * WaterLevelOusideBreach^(1.5);
    elseif WaterLevelInsideBreach > (2/3) * WaterLevelOusideBreach
        FlowThroughBreach = ((2 * Gravity)^0.5) * WidthBreach * WaterLevelDifference^(0.5) * WaterLevelInsideBreach;
    else
        debug
    end
end