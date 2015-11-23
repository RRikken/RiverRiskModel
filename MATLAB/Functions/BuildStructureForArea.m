function [ AreaMapStructure, WaterContents, WaterLevelMap ] = BuildStructureForArea( BottomHeightMap )
%BUILDSTRUCTUREFORAREA Summary of this function goes here
%   Detailed explanation goes here
[ Rows, Columns ] = size(BottomHeightMap);
%%PreAllocate structure by assigning last value with NaN
            WaterLevelMap(1:Rows, 1:Columns) = NaN;
            WaterContents(1:Rows, 1:Columns) = NaN;
            AreaMapStructure(Rows, Columns).BottomHeight = NaN;
            AreaMapStructure(Rows, Columns).OutFlow = [NaN NaN;NaN NaN; NaN NaN;NaN NaN; NaN NaN];
            AreaMapStructure(Rows, Columns).InFlow = [NaN NaN;NaN NaN;NaN NaN;NaN NaN];
            AreaMapStructure(Rows, Columns).RowPosition = NaN;
            AreaMapStructure(Rows, Columns).ColumnPosition = NaN;

for Row = 1 : Rows
    for Column = 1 : Columns
        if isnan(BottomHeightMap(Row, Column)) == 0
            WaterContents(Row, Column) = 0;
            WaterLevelMap(Row, Column) = BottomHeightMap(Row, Column);
            AreaMapStructure(Row, Column).BottomHeight = BottomHeightMap(Row, Column);
            AreaMapStructure(Row, Column).OutFlow = [1 0;2 0;3 0;4 0; 5 0];
            AreaMapStructure(Row, Column).InFlow = [1 0;2 0;3 0;4 0];
            AreaMapStructure(Row, Column).RowPosition = Row;
            AreaMapStructure(Row, Column).ColumnPosition = Column;
        else
            WaterContents(Row, Column) = NaN;
            WaterLevelMap(Row, Column) = NaN;
            AreaMapStructure(Row, Column).BottomHeight = NaN;
            AreaMapStructure(Row, Column).OutFlow = [NaN NaN;NaN NaN; NaN NaN;NaN NaN; NaN NaN];
            AreaMapStructure(Row, Column).InFlow = [NaN NaN;NaN NaN;NaN NaN;NaN NaN];
            AreaMapStructure(Row, Column).RowPosition = NaN;
            AreaMapStructure(Row, Column).ColumnPosition = NaN;
        end
    end
end
end