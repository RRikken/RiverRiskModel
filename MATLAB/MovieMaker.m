%Load all of the data files
Directory = 'Data\*.*';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 3:NumberOfFileIds
    load(FileNames(K).name);
end
clear FileNames Directory K NumberOfFileIds Values

    WaterHeights = WaterContentsArraysForGraphs(1:223,1:983,1);
    [n_Y,n_X] = size(ahn100_max);
    surf([1:n_X], [1:n_Y],flipud(WaterHeights),'EdgeColor','none'); view(2); colorbar; axis equal;
    axis([0 1000 -100 300])
    caxis([0,20000])
    xlabel('x (100 m)')
    ylabel('y (100 m)')
    title('Dijkringgebieden')

loops = 1000;
F(loops) = struct('cdata',[],'colormap',[]);
for j = 1:loops
    
    WaterHeights = WaterContentsArraysForGraphs(1:223,1:983,j);
    [n_Y,n_X] = size(ahn100_max);
    surf([1:n_X], [1:n_Y],flipud(WaterHeights),'EdgeColor','none'); view(2); colorbar; axis equal;
    axis([0 1000 -100 300])
    caxis([0,20000])
    xlabel('x (100 m)')
    ylabel('y (100 m)')
    title('Dijkringgebieden')
    drawnow
    
    F(j) = getframe(gcf);
end


v = VideoWriter('newfile1.avi');
open(v)
writeVideo(v, F)
close(v)
clear v F

loops = 1000;
F2(loops) = struct('cdata',[],'colormap',[]);
for j = 1:loops
    
    WaterHeights = WaterContentsArraysForGraphs(1:223,1:983,j + 1000);
    [n_Y,n_X] = size(ahn100_max);
    surf([1:n_X], [1:n_Y],flipud(WaterHeights),'EdgeColor','none'); view(2); colorbar; axis equal;
    axis([0 1000 -100 300])
    caxis([0,20000])
    xlabel('x (100 m)')
    ylabel('y (100 m)')
    title('Dijkringgebieden')
    drawnow
    
    F2(j) = getframe(gcf);
end

v2 = VideoWriter('newfile2.avi');
open(v2)
writeVideo(v2, F2)
close(v2)

