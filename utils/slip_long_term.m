clc
clear all
%close all

addpath(genpath('.'));
Magnitude=[6.0000,6.5000,6.8012,7.0737,7.3203,7.5435,7.7453,7.9280,8.0933,8.2429,8.3782,...
    8.5007,8.6115,8.7118,8.8025,8.8846,8.9588,9.0260];

[Prob,G]=assign_prob_Kagan(Magnitude);

list=dir('hellenic_Hazard_slip_DS1\variable_mu\*\Strasser\Slip*.dat');
%return
load('barycenters_all_HeA.mat');
Slip_tot=zeros(size(barycenters_all,1),1);
for i=1:length(list)
   if mod(i,100)==0
       i
   end
   Mw_string=list(i).folder(end-14:end-9);
   Mw_string(Mw_string=='_')='.';
   Mw=str2num(Mw_string);
   index=find(Magnitude==Mw);
   folder_quake=strcat('hellenic_Hazard_variDS/',list(i).folder(end-14:end));
   file_quake=strcat(folder_quake,'/QuakeArea_',list(i).name(end-12:end-8),'.dat');
   Quake=load(file_quake);
   Slip_m=load(strcat(list(i).folder,'/',list(i).name));
   Slip=Slip_m(:,11); %.Variables;
   if ~isnan(Slip)
    Slip_tot(Quake)=Slip_tot(Quake)+Slip*Prob(index);
   end
   clear index
end
Slip_tot=Slip_tot/sum(Slip_tot);
%% Depth binning

Depth=(-1e-3)*barycenters_all(:,3);

depth_bin=linspace(min(Depth),60,15);

index_structure=ones(length(depth_bin)-1,1);
for i=1:length(Depth)
    for j=1:length(depth_bin)-1
        if Depth(i)<=depth_bin(j+1) && Depth(i)>=depth_bin(j);
           depth_structure(j).depth(index_structure(j))=Depth(i);
           depth_structure(j).index(index_structure(j))=i;
           index_structure(j)=index_structure(j)+1;
           break
        end
    end
end

for j=1:length(depth_bin)-1
    depth_position(j)=0.5*(depth_bin(j)+depth_bin(j+1));
    depth_mean(j)=mean(Slip_tot(depth_structure(j).index));
end

figure(3); hold on
plot(depth_position,depth_mean,'r*')