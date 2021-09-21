clc
clear all
close all

addpath(genpath('..'));
fid=fopen('../config_files/Parameters/input.json');
Param=read_config_json(fid); fclose(fid);
Zone=Param.acronym;
load(strcat('barycenters_all_',Zone,'.mat'));
if (Param.Configure.application=='PTF')
    hypo=Param.Event.Hypo_LonLat;
end
folder=input('Enter folder name where plotting (start with output)\n\n','s');
list=dir(strcat('../',folder,'/Slip4HySea0*.dat'));
fprintf('Number of distribution to be plotted:  %d\n\n',length(list))
for j=1:length(list)
    if mod(j,20)==0
        fprintf('Slip distributions number %d done\n\n',j);
    end
    input_var=importdata(strcat(list(j).folder,'/',list(j).name)); %Initial_conditions_restr(:,2:12); %load('Input_HySea.txt');
    input=input_var.data;
    slip=input(:,11);
    figure('visible','off');
    set(gca,'FontSize',12,'FontWeight','bold');
    geoscatter(mean(input(:,[2 5 8])'),mean(input(:,[1 4 7])'),150,slip,'s','filled');
    hold on
    geolimits([min(input(:,2))-1 max(input(:,2))+1], ...
        [min(input(:,1)) max(input(:,1))])
    if (Param.Configure.application=='PTF')
        geoplot(hypo(2),hypo(1),'kp','MarkerSize',15,'MarkerFaceColor','y');
    end
    geobasemap('topographic')
    colormap('jet');
    colorbar;
    title('Slip (m)');
    saveas(gcf,strcat(list(j).folder,'/',list(j).name,'.png'),'png')
    hold off
    clear input_var input slip
    close all
end