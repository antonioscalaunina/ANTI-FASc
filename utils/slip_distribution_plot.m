clc
clear all
close all
load('barycenters_all_MaK.mat');
list=dir('..\output\makran_Hazard_slip\homogeneous_mu\7_0737\Strasser\Slip4HySea0*.dat');
for j=1:length(list)
    input_var=importdata(strcat(list(j).folder,'/',list(j).name)); %Initial_conditions_restr(:,2:12); %load('Input_HySea.txt');
    input=input_var.data;
    slip=input(:,11);
    figure(1);
    set(gcf','visible','off');
    set(gca,'FontSize',12,'FontWeight','bold');
    geoscatter(mean(input(:,[2 5 8])'),mean(input(:,[1 4 7])'),150,slip,'s','filled');
    hold on
    geolimits([min(input(:,2))-1 max(input(:,2))+1], ...
        [min(input(:,1)) max(input(:,1))])
    geobasemap('topographic')
    colormap('jet');
    colorbar;
    title('Slip (m)');
    saveas(gcf,strcat(list(j).folder,'/',list(j).name,'.png'),'png')
    hold off
    clear input_var input slip
end