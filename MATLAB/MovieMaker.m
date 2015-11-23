%Load all of the data files
Directory = 'Data\*.*';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 3:NumberOfFileIds
    load(FileNames(K).name);
end
clear FileNames Directory K NumberOfFileIds Values

    WaterHeights = TotalDamageMap(:,:,600);
    [n_Y,n_X] = size(WaterHeights);
    surf([1:n_X], [1:n_Y],flipud(WaterHeights),'EdgeColor','none'); view(2); colorbar; axis equal;
    axis([100 500 0 250])
    caxis([0,1000000])
    xlabel('x (100 m)')
    ylabel('y (100 m)')
    title('Dijkringgebieden')

loops = 600;
F(loops) = struct('cdata',[],'colormap',[]);
for j = 601 : 1200
    
     WaterHeights = TotalDamageMap(:,:,j);
    [n_Y,n_X] = size(WaterHeights);
    surf([1:n_X], [1:n_Y],flipud(WaterHeights),'EdgeColor','none'); view(2); axis equal;
    axis([100 500 0 250])
    caxis([0,1000000])
    xlabel('x (100 m)')
    ylabel('y (100 m)')
    title('Dijkringgebieden')
    ColorBar = colorbar;
    ColorBar.Label.String = 'Damage in Euros';
    ColorBar.Label.FontSize = 20;
    drawnow
    
    F(j - 600) = getframe(gcf);
end


v = VideoWriter('GraphsAndMovies\5_2_1200frames200x200TotalDamage2.avi');
open(v)
writeVideo(v, F)
close(v)