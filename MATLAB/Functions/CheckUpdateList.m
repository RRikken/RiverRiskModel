function [ NewItemsList ] = CheckUpdateList(UpdateList, WaterOutflowVolumes, WaterContents, SurroundingCells)

if sum(WaterOutflowVolumes(1:4,2)) < 0.00000001
    NewItemsList = [];
else
    NewItemsList = [];
    for ind = 1 : 4
        if WaterOutflowVolumes(ind,2) > 0.00000001 && WaterContents(ind) < 0.00000001
            SelectedCell = [ SurroundingCells(ind,1) SurroundingCells(ind,2) ];
            
            n=floor(log10(SelectedCell(2)));
            UniqueID = 10^(n+1)*SelectedCell(1) + SelectedCell(2);
            
            ListLogical = UpdateList(:,3) == UniqueID;
            IsIDInUpdateList = any(ListLogical);
            
            if IsIDInUpdateList == 0
                SelectedCell = [ SelectedCell UniqueID];
                NewItemsList = [ NewItemsList; SelectedCell];
            end
        end
    end
end
end