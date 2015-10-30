function [ AreaMapStructure, WaterContents ] = BuildStructureForArea( BottomHeightMap, AreaSize )
%BUILDSTRUCTUREFORAREA Summary of this function goes here
%   Detailed explanation goes here
[ Rows, Columns ] = size(BottomHeightMap);
%%PreAllocate structure by assigning last value with NaN
            AreaMapStructure(Rows, Columns).BottomHeight = NaN;
            AreaMapStructure(Rows, Columns).AreaSize = NaN;
            WaterContents(1:Rows, 1:Columns) = NaN;
            AreaMapStructure(Rows, Columns).OutFlow = [NaN NaN;NaN NaN; NaN NaN;NaN NaN; NaN NaN];
            AreaMapStructure(Rows, Columns).InFlow = [NaN NaN;NaN NaN;NaN NaN;NaN NaN];
            AreaMapStructure(Rows, Columns).WaterDepth = NaN;
            AreaMapStructure(Rows, Columns).WaterLevel = NaN;
            AreaMapStructure(Rows, Columns).RowPosition = NaN;
            AreaMapStructure(Rows, Columns).ColumnPosition = NaN;

for Row = 1 : Rows
    for Column = 1 : Columns
        if isnan(BottomHeightMap(Row, Column)) == 0
            AreaMapStructure(Row, Column).BottomHeight = BottomHeightMap(Row, Column);
            AreaMapStructure(Row, Column).AreaSize = AreaSize;
            WaterContents(Row, Column) = 0;
            AreaMapStructure(Row, Column).OutFlow = [1 0;2 0;3 0;4 0; 5 0];
            AreaMapStructure(Row, Column).InFlow = [1 0;2 0;3 0;4 0];
            AreaMapStructure(Row, Column).WaterDepth = 0;
            AreaMapStructure(Row, Column).WaterLevel = BottomHeightMap(Row, Column);
            AreaMapStructure(Row, Column).RowPosition = Row;
            AreaMapStructure(Row, Column).ColumnPosition = Column;
        else
            AreaMapStructure(Row, Column).BottomHeight = NaN;
            AreaMapStructure(Row, Column).AreaSize = NaN;
            WaterContents(Row, Column) = NaN;
            AreaMapStructure(Row, Column).OutFlow = [NaN NaN;NaN NaN; NaN NaN;NaN NaN; NaN NaN];
            AreaMapStructure(Row, Column).InFlow = [NaN NaN;NaN NaN;NaN NaN;NaN NaN];
            AreaMapStructure(Row, Column).WaterDepth = NaN;
            AreaMapStructure(Row, Column).WaterLevel = NaN;
            AreaMapStructure(Row, Column).RowPosition = NaN;
            AreaMapStructure(Row, Column).ColumnPosition = NaN;
        end
    end
end
end