% This script generates the mesh file in a format compatible with the
% typical cubit format (*.inp) and a matlab matrix containg the connection
% cell for all the mesh elements

clc
clear all
close all


addpath(genpath('..'));
fid=fopen('../config_files/Parameters/input.json');
Zone=read_config_json(fid);
fclose(fid);

load('string1.mat'); load('string2.mat'); load('string3.mat');
string1{2}=strcat('cubit(',pwd,'):',date,':');

% disp('WARNING: Please check in the folder utils/sz_slab the right name of the folder slab');
% nameofslab=input('Please enter the name of the slab (in the form "nameslab") \n\n');
nameofslab=Zone.zone_name;

nodes=load(strcat(nameofslab,'_mesh_nodes.dat'));
nodes((nodes(:,2)>180),2)=nodes((nodes(:,2)>180),2)-360;
cells=load(strcat(nameofslab,'_mesh_faces.dat'));

% disp('WARNING: Choose a three digits acronym then update the file utils/Table_slabs.dat with your choice');
% disp('WARNING: Remember to change this acronym in the file /preprocess/matrix_connection_gen/param_zone_input.dat');
% disp('         along with the right mercator zone');
% disp('WARNING: The same acronym will be used later in the execution of Rupture_areas_OF.m')
% slab_acronym=input('Please digit an acronym for the slab (in the form "AaA") \n\n');
slab_acronym=Zone.acronym;
namefile=strcat(slab_acronym,'_mesh_15km.inp');

fid=fopen(namefile,'w');

for i=1:length(string1)
    fprintf(fid,'%s\n',string1{i});
end

fprintf(fid,'%d, %20.10e, %20.10e, %15.6e\n',...
    [nodes(:,1) nodes(:,2) nodes(:,3) nodes(:,4)].'); 

for i=1:length(string2)
    fprintf(fid,'%s\n',string2{i});
end

fprintf(fid,'%d, %8d, %8d, %8d\n',...
    [cells(:,1) cells(:,2) cells(:,3) cells(:,4)].');

for i=1:length(string3)
    fprintf(fid,'%s\n',string3{i});
end

fclose(fid);

fid=fopen('matrix_connection_gen/param_zone_input.dat','w');
fprintf(fid,'!### Geo zone (Three digit acronym)\n');
fprintf(fid,'%s\n',slab_acronym);
fprintf(fid,'!#### Mercator projection zone\n');
fprintf(fid,'%d\n',Zone.Merc_zone);
fclose(fid);