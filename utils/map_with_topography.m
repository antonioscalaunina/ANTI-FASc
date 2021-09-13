clc
close all
clear all


%input_var=readtable('Alaska20210729_061550_M82_W15797_N5560_slip\homogeneous_mu\8_2429\Strasser\Slip4HySea00394_005.dat'); %Initial_conditions_restr(:,2:12); %load('Input_HySea.txt');
%input=input_var(:,:).Variables;
addpath('m_map\');
list=dir('..\output\makran_Hazard_slip\homogeneous_mu\9_0260\Strasser\Slip4HySea0*.dat');
for j=1:length(list)
    input_var=readtable(strcat(list(j).folder,'/',list(j).name)); %Initial_conditions_restr(:,2:12); %load('Input_HySea.txt');
    input=input_var(:,:).Variables;
    slip=input(:,11);
    minlon=min(min(input(:,[1 4 7]))); maxlon=max(max(input(:,[1 4 7])));
    minlat=min(min(input(:,[2 5 8]))); maxlat=max(max(input(:,[2 5 8])));


    figure(1)
    set(gcf,'visible','off');
    set(gca,'FontSize',12,'FontWeight','bold');
    %m_proj('lambert','lon',[18 30],'lat',[33 39]); 
    m_proj('mercator','lon',[minlon-1 maxlon+1],'lat',[minlat-1 maxlat+1]);

    %[CS,CH]=m_etopo2('contourf',[-5000:1000:0 200:200:2000],'edgecolor','none');
    % [CS,CH]=m_etopo2('contourf',[-5000:200:0],'edgecolor','none');
 
    %m_grid('linestyle','none','tickdir','out','linewidth',3);
    %m_grid('box','fancy','linestyle','none','backcolor',[.1 0.5 0.7]);
    hold on
    %colormap([ m_colmap('blue',80); m_colmap('gland',48)]);
    %colormap([ m_colmap('blue',80)]);
    %brighten(.5);

    %ax=m_contfbar(1,[.5 .8],CS,CH);
    %title(ax,{'Level/m',''}); % Move up by inserting a blank line
    m_gshhs_h('patch',[.8 .8 .8]);
    m_gshhs_h('color',[.0 .0 .0],'LineWidth',1);
    m_grid('box','fancy','linestyle','none','backcolor',[.1 0.5 0.7]);
    xlabel('Longitude'); ylabel('Latitude'); set(gca,'FontSize',14,'FontWeight','bold');
%return
% input_var=readtable('..\calabrian_Hazard_slip\homogeneous_mu\8_2429\Strasser\Slip4HySea00319_001.dat'); %Initial_conditions_restr(:,2:12); %load('Input_HySea.txt');
% input=input_var(:,:).Variables;
% slip=input(:,11);
    maximum=max(slip);
    %maximum=19.6894
    minimum=0;
    cc=jet(101);

for i=1:size(input,1)
    if slip(i)>0
    [X,Y]=m_ll2xy(input(i,[1 4 7 1]),input(i, [2 5 8 2]));
        if slip(i)> maximum
           fill(X,Y,cc(101,:),'Edgecolor','none')
           %alpha(0.25);
        else
           fill(X,Y,cc(ceil(1+100*((((slip(i)-minimum))/(maximum-minimum)))),:),'Edgecolor','none')
           %alpha(0.25);
        end
    end
end

%[Xhypo,Yhypo]=m_ll2xy(-157.97,55.60);
%figure(1)
%plot(Xhypo,Yhypo,'pr','MarkerSize',8,'MarkerFaceColor','r')
 % figure
  colormap('jet')
  colorbar
  caxis([minimum maximum])
  title('Slip (m)')
  
  saveas(gcf,strcat(list(j).folder,'/',list(j).name,'.png'),'png')
  hold off
end