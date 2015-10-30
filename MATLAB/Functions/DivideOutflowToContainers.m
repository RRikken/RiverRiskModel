function WaterContainerMap = DivideOutflowToContainers(WaterContainerMap, Row, Column )
%DIVIDEOUTFLOWTOCONTAINERS Summary of this function goes here
%   Detailed explanation goes here
OutFlow = WaterContainerMap(Row, Column).OutFlow;
OutFlowAndPosition = double.empty();
for i = 1 : 5
    if OutFlow(i,2) > 0
        switch i
            case 1
                OutFlowAndPosition = [Row, Column, OutFlow(1,2)];
                WaterContainerMap( Row - 1, Column ).InFlow = OutFlowAndPosition;
            case 2
                OutFlowAndPosition = [Row, Column,  OutFlow(2,2)];
                WaterContainerMap( Row, Column - 1 ).InFlow = OutFlowAndPosition;
            case 3
                OutFlowAndPosition = [Row, Column, OutFlow(3,2)];
                WaterContainerMap( Row, Column + 1).InFlow = OutFlowAndPosition;
            case 4
                OutFlowAndPosition = [Row, Column, OutFlow(4,2)];
                WaterContainerMap( Row + 1, Column ).InFlow = OutFlowAndPosition;
            case 5
                WaterContainerMap(Row, Column).WaterContents = WaterContainerMap(Row, Column).WaterContents + OutFlow(5,2);
        end
    end
end

end

