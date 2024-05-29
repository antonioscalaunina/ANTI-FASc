clc
clear all
close all

addpath(genpath('..'));


list=dir('..\output\calabrian_Hazard_slip_CaA_NOstrdrop\variable_mu\*\Strasser\Slip4Hy*.dat');

load('barycenters_all_CaA.mat');
Slip_tot=zeros(size(barycenters_all,1),1);
for i=1:length(list)
   Slip_tot=zeros(size(barycenters_all,1),1);
   if mod(i,100)==0
       i
   end
   Slip4cells=zeros(length(barycenters_all),1);
   folder_quake=strcat('../input/calabrian_Hazard_NOstrdrop/',list(i).folder(end-14:end));
   file_quake=strcat(folder_quake,'/QuakeArea_',list(i).name(end-12:end-8),'.dat');
   Quake=load(file_quake);
   Slip_m=importdata(strcat(list(i).folder,'/',list(i).name));
   Slip_m=Slip_m.data;
   Slip=Slip_m(:,11); %.Variables;
   Slip4cells(Quake)=Slip;
   fid=fopen((strcat(list(i).folder,'/Slip4cells_',list(i).name(end-12:end))),'w');
   fprintf(fid,'%10.4f\n',Slip4cells.');
   fclose(fid);
   clear Quake Slip*
   
   
   
end
