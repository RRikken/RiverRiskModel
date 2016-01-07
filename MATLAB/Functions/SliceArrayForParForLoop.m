function [ ArrayForParForLoop ] = SliceArrayForParForLoop( ReducedArray, FullArray, Start )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[ Rows, Columns ] = size( ReducedArray );

ArrayForParForLoop = cell( Rows, Columns);

if strcmp(Start, 'StartAt_1,1')
    for Row = 1 : Rows
        for Column = 1 : Columns
            if ReducedArray( Row, Column ) > 0
                ArraySlice = FullArray( Row * 2 - 1 : Row * 2, Column * 2 - 1 : Column * 2  );
                ArrayForParForLoop{ Row, Column } = ArraySlice;
            end
        end
    end
elseif strcmp(Start, 'StartAt_2,2')
    for Row = 1 : Rows
        for Column = 1 : Columns
            if ReducedArray( Row, Column ) > 0
                ArraySlice = FullArray( Row * 2 : Row * 2 + 1, Column * 2 : Column * 2 + 1  );
                ArrayForParForLoop{ Row, Column } = ArraySlice;
            end
        end
    end
elseif strcmp(Start, 'ReduceHeightMap_StartAt_1,1')
    for Row = 1 : Rows
        for Column = 1 : Columns
            ArrayForParForLoop{ Row, Column } = FullArray( Row * 2 - 1 : Row * 2, Column * 2 - 1 : Column * 2  );
        end
    end
elseif strcmp(Start, 'ReduceHeightMap_StartAt_2,2')
    for Row = 1 : Rows
        for Column = 1 : Columns
            ArrayForParForLoop{ Row, Column } = FullArray( Row * 2 : Row * 2 + 1, Column * 2 : Column * 2 + 1 );
        end
    end
end