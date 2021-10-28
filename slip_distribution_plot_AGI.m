clc
clear all
close all

addpath(genpath('..'));
fid=fopen('../config_files/Parameters/input.json');
Param=read_config_json(fid); fclose(fid);
Zone=Param.acronym;
%load(strcat('../config_files/Barycenters/barycenters_all_',Zone,'.mat'));
if (Param.Configure.application=='PTF')
    hypo=Param.Event.Hypo_LonLat;
end
%output/*name_folder*_slip/*rigidity*/*magnitude*/*scaling_law*
values=["event" "rigidity distribution" "magnitude" "scaling law"];
folder='../output/';
for ilev=1:4
    fprintf('Current folder is ''%s''\n\n',folder)
    choices=dir(folder);
    choices=choices(3:end);
    if length(choices)==1
        fprintf('There is only one %s directory\n\n',values(ilev))
        folder=strcat(folder,choices(1).name,'/');
        pause(1.5)
    else
        idir=0;
        while or(idir<1,or(idir>length(choices),(round(idir)-idir)~=0))
            fprintf('Choose your %s directory between:\n',values(ilev));
            for ndir=1:length(choices)
                fprintf('%d. %s/\n',ndir,choices(ndir).name)
            end
            idir=input(sprintf('Insert a number between 1 and %d:\n\n',length(choices)));
            while ~isnumeric(idir)
                idir=input(sprintf('Insert a number between 1 and %d:\n\n',length(choices)));
            end
            
        end
        folder=strcat(folder,choices(idir).name,'/');
	
    end
    
    clc
    
end
% folder=input('Enter folder name where plotting (start with output)\n\n','s');
list=dir(strcat(folder,'/Slip4HySea0*.dat'));
fprintf('Number of distributions to be plotted:  %d\n\n',length(list))
udp=textprogressbar(length(list));
for j=1:length(list)
    %if mod(j,20)==0
     %   fprintf('Slip distributions number %d done\n\n',j);
    %end
    udp(j);
    if ~isfile(strcat(list(j).folder,'/',list(j).name,'.png'))
        input_var=importdata(strcat(list(j).folder,'/',list(j).name)); %Initial_conditions_restr(:,2:12); %load('Input_HySea.txt');
        input=input_var.data;
        slip=input(:,11);
        figure('visible','off');
        set(gca,'FontSize',12,'FontWeight','bold');
        geoscatter(mean(input(:,[2 5 8])'),mean(input(:,[1 4 7])'),150,slip,'s','filled');
        hold on
        gap=max(input)-min(input);
        geolimits([min(input(:,2))-0.25*gap(2) max(input(:,2))+0.25*gap(2)], ...
            [min(input(:,1))-0.25*gap(1) max(input(:,1))+0.25*gap(1)])
        if (Param.Configure.application=='PTF')
            geoplot(hypo(2),hypo(1),'kp','MarkerSize',15,'MarkerFaceColor','y');
        end
        geobasemap('topographic')
        colormap('jet');
        colorbar;
        title('Slip (m)');
        saveas(gcf,strcat(list(j).folder,'/',list(j).name(1:end-4),'.png'),'png')
        hold off
        clear input_var input slip
        close all
    end
end
