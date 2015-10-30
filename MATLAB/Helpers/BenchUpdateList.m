RowPosition= 118;
ColumnPosition = 583;

SurroundingCells = zeros(4,2);
SurroundingCells(1:4,1) = RowPosition;
SurroundingCells(1:4,2) = ColumnPosition;
SurroundingCells = SurroundingCells + [ -1 0; 0 -1; 0 1; 1 0; ];
WaterContents = [0 0 24000 0];

UpdateList = [118 583 118583;118 584 118584;118 585 118585];
WaterOutflowVolumes = [1 18770.0000000000;2 5230.00000000001;3 0;4 0;5 0];

[ NewItemsList ] = CheckUpdateList(UpdateList, WaterOutflowVolumes, WaterContents, SurroundingCells)