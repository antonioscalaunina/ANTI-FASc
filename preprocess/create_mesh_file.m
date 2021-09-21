% This script generates the mesh file in a format compatible with the
% typical cubit format (*.inp) and a matlab matrix containg the connection
% cell for all the mesh elements

clc
clear all
close all
tic

%addpath(genpath('..'));
disp('Reading input file');
fid=fopen('../config_files/Parameters/input.json');
Zone=read_config_json(fid);
fclose(fid);
mesh_from_slab=Zone.mesh_gen;
load('string1.mat'); load('string2.mat'); load('string3.mat');
string1{2}=strcat('cubit(',pwd,'):',date,':');
nameofslab=Zone.zone_name;

if mesh_from_slab
    disp("Now I'm meshing (from the file you provided)");
    [Lat,Lon,mesh_default,depth_interp]=mesh_from_Slab(Zone.slab_file,Zone.Merc_zone,...
                                        Zone.seismog_depth,Zone.depth_interpolator,Zone.element_size);
    if isempty(mesh_default)
        return
    end
    nodes(:,1)=(1:size(Lat,2));
    nodes(:,2:3)=[Lon' Lat'];
    nodes(:,4)=depth_interp;
    nodes((nodes(:,2)>180),2)=nodes((nodes(:,2)>180),2)-360;
    cells(:,1)=(1:size(mesh_default.Elements,2))';
    cells(:,2:4)=mesh_default.Elements';
    fid=fopen(strcat(nameofslab,'_mesh_nodes.dat'),'w');
    fprintf(fid,'%d %20.10e %20.10e %15.6e\n',...
    [nodes(:,1) nodes(:,2) nodes(:,3) nodes(:,4)].');  fclose(fid);
    fid=fopen(strcat(nameofslab,'_mesh_faces.dat'),'w');
    fprintf(fid,'%d %8d %8d %8d\n',...
    [cells(:,1) cells(:,2) cells(:,3) cells(:,4)].'); fclose(fid);
    mkdir(strcat('../utils/sz_slabs/',nameofslab));
    mkdir(strcat('../utils/sz_slabs/',nameofslab,'/subfaults'));
    movefile(strcat(nameofslab,'_mesh_nodes.dat'),strcat('../utils/sz_slabs/',nameofslab,'/subfaults'));
    movefile(strcat(nameofslab,'_mesh_faces.dat'),strcat('../utils/sz_slabs/',nameofslab,'/subfaults'));
else
    disp("Great! You already have nodes and cells, I'm just writing\n")
    if isfile(strcat('../utils/sz_slabs/',nameofslab,'/subfaults/',nameofslab,'_mesh_nodes.dat'))
        nodes=load(strcat(nameofslab,'_mesh_nodes.dat'));
    else
        disp('ERROR: Nodes file not in the sz database. Please check the name of slab');
        return
    end
    nodes((nodes(:,2)>180),2)=nodes((nodes(:,2)>180),2)-360;
    if isfile(strcat('../utils/sz_slabs/',nameofslab,'/subfaults/',nameofslab,'_mesh_faces.dat'))
        cells=load(strcat(nameofslab,'_mesh_faces.dat'));
    else
        disp('ERROR: Faces file not in the sz database. Please check the name of slab');
        return
    end
end
    

% disp('WARNING: Please check in the folder utils/sz_slab the right name of the folder slab');
% nameofslab=input('Please enter the name of the slab (in the form "nameslab") \n\n');
% disp('WARNING: Choose a three digits acronym then update the file utils/Table_slabs.dat with your choice');
% disp('WARNING: Remember to change this acronym in the file /preprocess/matrix_connection_gen/param_zone_input.dat');
% disp('         along with the right mercator zone');
% disp('WARNING: The same acronym will be used later in the execution of Rupture_areas_OF.m')
% slab_acronym=input('Please digit an acronym for the slab (in the form "AaA") \n\n');
slab_acronym=Zone.acronym;
namefile=strcat('matrix_connection_gen/',slab_acronym,'_mesh_15km.inp');

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
t=toc;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Lat,Lon,mesh_default,depth_interp]=mesh_from_Slab(file,Merc,seismog_depth,depth_int,el_size)
    

file=strcat('../utils/sz_slabs/',file);
if (file(end-2:end)=='xyz')
    SLAB=importdata(file);
elseif (file(end-2:end)=='grd')
    x=ncread(file,'x'); y=ncread(file,'y'); z=ncread(file,'z');
    [Y,X]=meshgrid(y,x);
    SLAB(:,1)=reshape(X,size(X,1)*size(X,2),1);
    SLAB(:,2)=reshape(Y,size(Y,1)*size(Y,2),1);
    SLAB(:,3)=reshape(z,size(z,1)*size(z,2),1);
else
    disp('ERROR: Format file not readable. PLEASE CHECK!!!');
    Lat=[];Lon=[];mesh_default=[];depth_interp=[];
    return
end
disp("Depth interpolation: this may take few minutes"); 
SLAB=[SLAB(SLAB(:,3)>-seismog_depth,1) SLAB(SLAB(:,3)>-seismog_depth,2) SLAB(SLAB(:,3)>-seismog_depth,3)];
[SLAB_UTM(:,1),SLAB_UTM(:,2)]=ll2utm(SLAB(:,2),SLAB(:,1),Merc);
SLAB_boundary=boundary(SLAB(:,1),SLAB(:,2),0.5);
SLAB4mesh=SLAB(SLAB_boundary,:);
[X,Y]=ll2utm(SLAB4mesh(:,2),SLAB4mesh(:,1),Merc);
Polygon=[2 length(SLAB4mesh) X' Y']'; %Japan4mesh(:,1)' Japan4mesh(:,2)']';
g=decsg(Polygon);
model=createpde;
geometryFromEdges(model,g);
%figure
%pdegplot(model) %,'EdgeLabels','on')
%axis equal

mesh_default=generateMesh(model,'Hmax',el_size,'Hmin',el_size,'GeometricOrder','linear','Hgrad',1);
%pdeplot(mesh_default);
%%
depth_interp=griddata(SLAB_UTM(:,1),SLAB_UTM(:,2),SLAB(:,3),mesh_default.Nodes(1,:)',mesh_default.Nodes(2,:)',depth_int);
depth_interp=1000*depth_interp;
[Lat,Lon]=utm2ll(mesh_default.Nodes(1,:),mesh_default.Nodes(2,:),Merc);
%figure
%geoscatter(Lat,Lon,50,depth_interp,'filled');
%hold on
%alpha(0.55); geobasemap('streets');
end
