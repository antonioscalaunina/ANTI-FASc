
function plot_slip_on_map_test(cells_mesh,feat,colorbar_logic,hypo_GEO)

addpath('C:\Users\ascal\Documents\MATLAB')
min_lon=180;
max_lon=-180;
min_lat=90;
max_lat=-90;
%HF=load('HF_3D_only_nodes.dat');
for i=1:length(cells_mesh)
   for j=1:4
       if cells_mesh(i).nodes(j,1)<min_lon
           min_lon=cells_mesh(i).nodes(j,1);
       end
       if cells_mesh(i).nodes(j,1)>max_lon
           max_lon=cells_mesh(i).nodes(j,1);
       end
       if cells_mesh(i).nodes(j,2)<min_lat
           min_lat=cells_mesh(i).nodes(j,2);
       end
       if cells_mesh(i).nodes(j,2)>max_lat
           max_lat=cells_mesh(i).nodes(j,2);
       end
   end
end
   %min_lat=35.4294;
   %max_lat=36.0857;
   cc=parula(101);

   maximum=max(feat); % 0.0022; %60. %1 %0.0022 %0.0021Hellenic;  0.0053Calabrian;   0.0085Cyprian
   minimum=min(feat);
   

    figure
    
    ax1=axes;
    if nargin==3
        xlim([min_lon max_lon ])
        ylim([min_lat max_lat ])
    else
        xlim([hypo_GEO(1)-4 hypo_GEO(1)+4])
        ylim([hypo_GEO(2)-4 hypo_GEO(2)+4])
    end
    %axis equal

    hold on
    
    ax2=axes;
    if nargin==3
        xlim([min_lon max_lon ])
        ylim([min_lat max_lat ])
    else
        xlim([hypo_GEO(1)-4 hypo_GEO(1)+4])
        ylim([hypo_GEO(2)-4 hypo_GEO(2)+4])
    end
        %axis equal
    hold on
    rupture_index=find(feat>0);
    for i=rupture_index'
        %i
        if isnan(feat(i))
            feat(i)=min(feat);
        end
        X=(cells_mesh(i).nodes(:,1));
        Y=(cells_mesh(i).nodes(:,2));
        if feat(i)>= maximum
            fill(X,Y,cc(101,:),'Edgecolor','none')
            %alpha(0.75)
        else
            fill(X,Y,cc(ceil(1+100*((((feat(i)-minimum))/(maximum-minimum)))),:),'Edgecolor','none')
            %alpha(0.75)
        end
        if nargin==4
            plot(hypo_GEO(1),hypo_GEO(2),'go','MarkerSize',10,'MarkerFaceColor','g')
        end
    end
    linkaxes([ax1,ax2])
    %%Hide the top axes
    %ax2.Visible = 'off';
    
    if (colorbar_logic)
        h=colorbar;
        caxis([minimum maximum])
        set(h,'Location','EastOutside','FontSize',14,'FontWeight','bold');
        %h.Label.color='r';
        %set(get(h,'title'),'string','Slip (m)');
        
    end
 
    ax3=axes;
    %axis equal
    set([ax1,ax2,ax3],'Position',[.17 .11 .685 .815]);  %[.17 .11 .685 .815]
    axes(ax3)
    if nargin==3
        xlim([min_lon max_lon])
        ylim([min_lat max_lat])
    else
        xlim([hypo_GEO(1)-4 hypo_GEO(1)+4])
        ylim([hypo_GEO(2)-4 hypo_GEO(2)+4])
    end
    styleParams = '&style=saturation:50&style=feature:transit|visibility:off&style=feature:road|visibility:off&style=feature:road.highway|visibility:off&&style=feature:water|element:geometry|color:0x52c3d4&style=feature:water|element:labels|visibility:off&style=element:labels.text|weight:2.5|gamma:2.25&style=feature:water|element:labels|visibility:off&style=feature:administrative.locality|visibility:on';
    plot_google_map('maptype','terrain','style',styleParams,'APIKey','AIzaSyDMSjokr-3WVHSYtZeW5xM2gI6uO8BkiMI')
    ax3.FontSize=16; ax3.FontWeight='bold';
    linkaxes([ax1,ax2,ax3])
   
    ax2.Visible = 'off';
    ax1.Visible='off';
    ax1.XTick = [];
    ax1.YTick = [];
%     ax3.XTick = ax2.XTick;
%     ax3.YTick = ax2.YTick;
    axes(ax1);
    axes(ax2);
    
end
    
% % % % % % %     print(sprintf('./Immagini/Map_Ranef_PDs_IDs_T%ss.png',name(nT)),'-dpng')
% % % % % % %     print(sprintf('./Immagini/Map_Ranef_FM_PDs_IDs_T%ss.png',name(nT)),'-dpng')
% % % % % %     print(sprintf('./Immagini/Map_Sta_Eve.png'),'-dpng')
    
% end
%axis([4 21 36 48])
%axis([6 19 43 48])

% axis([12.5 16.5 39.5 43.2]) %good