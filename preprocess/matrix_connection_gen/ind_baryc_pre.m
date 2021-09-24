clc
clear all
close all
tic

addpath(genpath('../..')); addpath('.');

%% Saving element2element matrix in mat file

fid=fopen('../../config_files/Parameters/input.json'); %read input from Json file
Param=read_config_json(fid); fclose(fid);
disp('Saving Element to Element connection file')
zone_code=Param.acronym;
filename=strcat('EToE_',zone_code,'.mat');
load('./EToE.dat');
for i=1:size(EToE,1)
    for j=1:size(EToE,2)
        if EToE(i,j)==i
            EToE(i,j)=0;
        end
    end
end
save(filename,'EToE');

%% Input to be checked for each case


%Zone='Makran'; % Variable for the folder name
%zone_code='MaK';  
%zone_code=Param.acronym; 
Slab.zone_code=zone_code; %Slab 
Merc_Zone=Param.Merc_zone;   %sMercator projection zone
Zone=Param.zone_name;
Sub_boundary_logic=logical(false);   
if Param.Configure.mesh_sub_boundary==1
    Sub_boundary_logic=logical(true);
end
Slab.Sub_boundary_logic=Sub_boundary_logic;         % logical: if the rupture can extend only on a part of the mesh          
%% Magnitude bins and scaling laws (Strasser and Murotani size in km - km^2)
% SL=load('scaling_laws'); Magnitude=SL(:,1); Slab.Magnitude=Magnitude;
fid=fopen('../../config_files/Parameters/scaling_relationship.json');
Scaling=read_config_json(fid); fclose(fid);

N_Magn_bins=Scaling.Magnitude_bins.number_bins;
Magnitude=Scaling.Magnitude_bins.Magnitude; Slab.Magnitude=Magnitude;
N_scaling=Scaling.Scaling_law.number; Slab.N_scaling=N_scaling;
Name_scaling=Scaling.Scaling_law.name;
Area_scaling=Scaling.Scaling_law.Area;
Length_scaling=Scaling.Scaling_law.Length;
if (length(Magnitude)~=N_Magn_bins); fprintf('ERROR: Number of Magnitude bin not correct\n'); return; end
if (length(Area_scaling)~=N_Magn_bins*N_scaling); fprintf('ERROR: Number of Area data not correct\n'); return; end 
if (length(Length_scaling)~=N_Magn_bins*N_scaling); fprintf('ERROR: Number of Length data not correct\n'); return; end
if (length(Name_scaling)~=N_scaling); fprintf('ERROR: Number of Scaling relationship not correct\n'); return; end
Area_aux=reshape(Area_scaling,N_Magn_bins,N_scaling);
Length_aux=reshape(Length_scaling,N_Magn_bins,N_scaling);
Width_aux=Area_aux./Length_aux;

%% read mesh, cell barycenters and boundary of seismogenic zone and rigidity yes/no

% barycenters = centers of the triangles
% Spatial probabIlity of each scenario TO BE DONE if using for PTF (for Hazard)!

name_filemesh=strcat(zone_code,'_mesh_15km.inp');
fid=fopen(name_filemesh); %Mesh file to be checked
[nodes,cells]=read_mesh_file(fid);
fclose(fid);
barycenters_all=find_barycenters(nodes,cells);
filename_baryc=strcat('barycenters_all_',zone_code);
save(filename_baryc,'barycenters_all');
if Slab.Sub_boundary_logic
    name_bnd=strcat('../../config_files/Mesh/',zone_code,'_boundary.txt');
    mesh_subbnd=readtable(name_bnd);
    bnd_mesh=[mesh_subbnd(:,1).Variables mesh_subbnd(:,2).Variables ,mesh_subbnd(:,3).Variables];
else
    bnd=boundary(nodes(:,1),nodes(:,2),1); 
    bnd_mesh=nodes(bnd,:);
end
%% Active barycenters for the whole subduction and selection of barycenters for case-study or hazard
min_bnd_dist=Param.Configure.minimum_bnd_distance;
int_dist=Param.Configure.minimum_interdistance;
elem_size=Param.element_size;

fprintf('Computing distances from the slab boundary\n');
[p0,distanceJB]=compute_distance2fault2D(bnd_mesh(:,:),barycenters_all(:,:),Sub_boundary_logic,Merc_Zone,0);
for i=1:length(Magnitude)
    for j=1:N_scaling % 1 Murotani - 2 Strasser
        index_active{i,j}=find(distanceJB>min(elem_size*5/1.e3,min_bnd_dist*Width_aux(i,j)));
    end
end
Slab.index_active=index_active;
fprintf('Done\n');
    
Slab.AreaSL=Area_aux; Slab.WidthSL=Width_aux; Slab.LengthSL=Length_aux; 
%Slab.index_magnitude=index_magnitude;  
Slab.nodes=nodes; Slab.cells=cells; Slab.barycenters_all=barycenters_all;
Slab.int_dist=int_dist; Slab.elem_size=elem_size;

[ind_aux_full]=select_barycenter2(Slab);   % use select_barycenter2 for adaptive 
                                                 % barycenter sampling with
                                                 % magnitude (otherwise
                                                 % select_barycenter takes
                                                 % all the barycenters)

filename=strcat('ind_aux_full_',zone_code);
save(filename,'ind_aux_full');
delete EToE.dat
movefile('ETo*.mat','../../config_files/Connection_cell/');
movefile('*mesh*.inp','../../config_files/Mesh/');
movefile('*matrix_distance.bin','../../config_files/Matrix_distances/');
movefile('ind_aux*','../../config_files/Barycenters/');
movefile('barycenters_all*','../../config_files/Barycenters/');


                                                 
return
%#######################################################################################################
function [ind_aux]=select_barycenter2(Slab)
% Samples the barycenters depending on the mangitude 
% (the larger the magnitude the coarser the spacing, depending on the specific scaling relationship)
% Selects all the barycenters within a distance 
% from the hypocenter  



barycenters_all=Slab.barycenters_all;
Length_aux=Slab.LengthSL; Magnitude=Slab.Magnitude;

N_scaling=Slab.N_scaling; int_dist=Slab.int_dist; elem_size=Slab.elem_size;

    index_active=Slab.index_active;
    l=0;
    fprintf('Barycenter selection\n')
    fprintf('This may take several minutes, but you will do only once for each mesh (and scaling law)\n')
    for i=1:length(Magnitude)
            fprintf('Magnitude bin # %d - Mw=%.4f \n',[i Magnitude(i)])
            l=l+1;
            for j=1:N_scaling
                if (isempty(index_active{i,j}) | int_dist*Length_aux(i,j)<0.5*elem_size/1e3)
                    barycenter{l,j}=index_active{i,j}';
                else
                    barycenter{l,j}(1)=index_active{i,j}(1);
                    kk=2;
                    for k=2:length(index_active{i,j})
                        for num=1:kk-1
                            Lon=[barycenters_all(index_active{i,j}(k),1) barycenters_all(barycenter{l,j}(num),1)];
                            Lat=[barycenters_all(index_active{i,j}(k),2) barycenters_all(barycenter{l,j}(num),2)];
                            dist_aux(num)=dist_wh(Lat,Lon);
                        end
                        if min(dist_aux)>int_dist*Length_aux(i,j)*1e3
                            barycenter{l,j}(kk)=index_active{i,j}(k);
                            kk=kk+1;
                        end
                        clear dist_aux
                    end
                end
            end
    end

        
        ind_aux=barycenter;
        %clear barycenter;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Barycenters = find_barycenters(nodes,cells)

nodes(nodes(:,1)<0,1)=nodes(nodes(:,1)<0,1)+360;
Barycenters=zeros(size(cells,1),3);
for i=1:size(cells,1)
    Barycenters(i,1)=sum(nodes(cells(i,:),1))/3;
    Barycenters(i,2)=sum(nodes(cells(i,:),2))/3;
    Barycenters(i,3)=sum(nodes(cells(i,:),3))/3;
end
Barycenters(Barycenters(:,1)>180,1)=Barycenters(Barycenters(:,1)>180,1)-360;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

