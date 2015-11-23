function [ WaterContentMap ] = PutOutflowIntoArea( WaterContentMap, RowPosition, ColumnPosition, OutFlow )
%PUTOUTFLOWINTOAREA Summary of this function goes here
%   Detailed explanation goes here
    [ Rows, Columns ] = size(WaterContentMap);
    
    % Above = Row - 1, Left = Column - 1, Right = Column + 1, Below = Row + 1 
    if OutFlow(1,2) > 0 && RowPosition - 1  > 0
       WaterContentMap(RowPosition - 1, ColumnPosition) = WaterContentMap(RowPosition - 1, ColumnPosition) + OutFlow(1,2);
       WaterContentMap(RowPosition, ColumnPosition) = WaterContentMap(RowPosition, ColumnPosition) - OutFlow(1,2);
    end
    if OutFlow(2,2) > 0 && ColumnPosition - 1 > 0
        WaterContentMap(RowPosition, ColumnPosition - 1) = WaterContentMap(RowPosition, ColumnPosition - 1) + OutFlow(2,2);
        WaterContentMap(RowPosition, ColumnPosition) = WaterContentMap(RowPosition, ColumnPosition) - OutFlow(2,2);
    end
    if OutFlow(3,2) > 0 && ColumnPosition + 1 <= Columns
        WaterContentMap(RowPosition, ColumnPosition + 1) = WaterContentMap(RowPosition, ColumnPosition + 1) + OutFlow(3,2);
        WaterContentMap(RowPosition, ColumnPosition) = WaterContentMap(RowPosition, ColumnPosition) - OutFlow(3,2);
    end
    if OutFlow(4,2) > 0 && RowPosition + 1 <= Rows
        WaterContentMap(RowPosition + 1, ColumnPosition) = WaterContentMap(RowPosition + 1, ColumnPosition) + OutFlow(4,2);
        WaterContentMap(RowPosition, ColumnPosition) = WaterContentMap(RowPosition, ColumnPosition) - OutFlow(4,2);
    end
end