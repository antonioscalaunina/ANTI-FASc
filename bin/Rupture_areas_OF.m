clc
clear all
close all
tic

%addpath('C:\Users\ascal\Documents\MATLAB')
%addpath(genpath('..')); addpath('.');

%% Input to be checked for each case
% Considered non-parameterized alternatives:
% 1 - Strasser VS Murotani
% 2 - Rigidity variable VS uniform (only SPDF to be combined with stochastic by the k2 code);

% Parameterized below:
% 1 - Zone (slab)
% 2 - Application (Hazard VS PTF/Testing)
% 3 - Shape of rupture areas (Circular VS Rectangular)

% To change the selection rules for PTF/Testing starting from the
% hypocenter go to select_barycenter(2) subroutines
% select barycenter2 around LINE 350:
%%% Computes barycenter/hypo distance and compares with L(Mw,Scaling)
% if dist_wh(Lat,Lon)<Length_aux(index_magnitude(i),j)*1e3  
%       barycenter{l,j}(kk)=ind_aux{i,j}(k);
%       kk=kk+1;
% end

fid=fopen('../config_files/Parameters/input.json'); %read input from Json file
Param=read_config_json(fid); fclose(fid);

%Zone='Makran'; % Variable for the folder name
%zone_code='MaK';  
zone_code=Param.acronym; Slab.zone_code=zone_code; %Slab 
Merc_Zone=Param.Merc_zone;   %sMercator projection zone
fid=fopen('../param_zone.dat','w');
fprintf(fid,'geo zone=%s',zone_code); fprintf(fid,'\n'); fprintf(fid,'mercator=%d',Merc_Zone);
fclose(fid);
Preprocess_logic=logical(false);
Sub_boundary_logic=logical(false);
Stress_drop_logic=logical(false);

if Param.Configure.preprocess==1
    Preprocess_logic=logical(true); % true: the active barycenters are already in preprocessing file
end
if Param.Configure.mesh_sub_boundary==1
    Sub_boundary_logic=logical(true);
end
if Param.Configure.Stress_drop_var==1
    Stress_drop_logic=logical(true);
end
    
Slab.Preprocess_logic=Preprocess_logic;

Slab.Sub_boundary_logic=Sub_boundary_logic;         % logical: if the rupture can extend only on a part of the mesh          

Slab.Stress_drop_logic=Stress_drop_logic;           % logical: if the stress drop varies with depth

application=Param.Configure.application; Slab.application=application;  %Hazard: All magnitude bins - all barycenters
                                                  %PTF:    Magnitude and location around estimated ones
shape=Param.Configure.shape; Slab.shape=shape;               %Rectangle for rectangular shape
                                                  %Circle for circular shape
                                                  
Fact_rigidity=Param.Configure.Fact_rigidity;  
                                        
switch application
    case ('PTF')
         Zone=Param.Event.Name;
         Mw=Param.Event.Magnitude; hypo_GEO=Param.Event.Hypo_LonLat;
         %Mw=9.0;  hypo_GEO=([62. 26.]);  % Magnitude and Location only for PTF case
         Mw_string=sprintf('%3.1f',Mw); Mw_string=Mw_string(Mw_string~='.');
         hypo_GEO_string{1}=sprintf('%6.2f',abs(hypo_GEO(1)));
         hypo_GEO_string{1}=hypo_GEO_string{1}(hypo_GEO_string{1}~='.');
         hypo_GEO_string{1}(isspace(hypo_GEO_string{1}))='0';
         if hypo_GEO(1)>=0.
            hypo_GEO_string{1}=strcat('E',hypo_GEO_string{1});
         else
            hypo_GEO_string{1}=strcat('W',hypo_GEO_string{1});
         end	 
         hypo_GEO_string{2}=sprintf('%5.2f',abs(hypo_GEO(2)));
         hypo_GEO_string{2}=hypo_GEO_string{2}(hypo_GEO_string{2}~='.');
         hypo_GEO_string{2}(isspace(hypo_GEO_string{2}))='0';
         if hypo_GEO(2)>=0.
            hypo_GEO_string{2}=strcat('N',hypo_GEO_string{2});
         else
            hypo_GEO_string{2}=strcat('S',hypo_GEO_string{2});
         end	    
         Slab.Mw=Mw; Slab.hypo_GEO=hypo_GEO;
         namefolder=strcat(Zone,'_M',Mw_string,'_',hypo_GEO_string{1},'_',hypo_GEO_string{2});
         namefolder_slip=strcat(namefolder,'_slip_',zone_code);
    case ('Hazard')
         Zone=Param.zone_name;
         namefolder=strcat(Zone,'_Hazard');
         namefolder_slip=strcat(namefolder,'_slip_',zone_code);
end	 
fid=fopen('../name_folders_file.dat','w');
fprintf(fid,'%s',namefolder); fprintf(fid,'\n'); fprintf(fid,'%s',namefolder_slip);
fprintf(fid,'\n'); fprintf(fid,'%s',zone_code);
fprintf(fid,'\n'); fprintf(fid,'%d',Param.Configure.numb_stoch);
fprintf(fid,'\n'); fprintf(fid,'%d',Param.Configure.variable_mu);
fclose(fid);
mkdir(strcat('../',namefolder)); mkdir(strcat('../',namefolder_slip));

%% Magnitude bins and scaling laws (Strasser and Murotani size in km - km^2)
% SL=load('scaling_laws'); Magnitude=SL(:,1); Slab.Magnitude=Magnitude;
fid=fopen('../config_files/Parameters/scaling_relationship.json');
Scaling=read_config_json(fid); fclose(fid);

N_Magn_bins=Scaling.Magnitude_bins.number_bins;
Magnitude=Scaling.Magnitude_bins.Magnitude; Slab.Magnitude=Magnitude;
N_scaling=Scaling.Scaling_law.number; Slab.N_scaling=N_scaling;
Name_scaling=Scaling.Scaling_law.name;
fid=fopen('../config_files/Parameters/classes_scaling.dat','w');
for j=1:N_scaling
    fprintf(fid,'%s\n',Name_scaling{j});
end
fclose(fid);
Area_scaling=Scaling.Scaling_law.Area;
Length_scaling=Scaling.Scaling_law.Length;
if (length(Magnitude)~=N_Magn_bins); fprintf('ERROR: Number of Magnitude bin not correct\n'); return; end
if (length(Area_scaling)~=N_Magn_bins*N_scaling); fprintf('ERROR: Number of Area data not correct\n'); return; end 
if (length(Length_scaling)~=N_Magn_bins*N_scaling); fprintf('ERROR: Number of Length data not correct\n'); return; end
if (length(Name_scaling)~=N_scaling); fprintf('ERROR: Number of Scaling relationship not correct\n'); return; end
Area_aux=reshape(Area_scaling,N_Magn_bins,N_scaling);
Length_aux=reshape(Length_scaling,N_Magn_bins,N_scaling);
Width_aux=Area_aux./Length_aux;
if Stress_drop_logic
    gamma1=Scaling.Scaling_law.gamma1; %Scaling.Scaling_law.gammal;
    gamma2=Scaling.Scaling_law.gamma2;
    gamma1=reshape(gamma1,1,N_scaling);
    gamma2=reshape(gamma2,1,N_scaling);
    Slab.gamma1=gamma1;
    Slab.gamma2=gamma2;
end

 %Magnitude bins
switch application
    case ('PTF')
	  if Param.Configure.file_baryc==1
             load(strcat('../config_files/PTF_selection/',Param.Configure.file_baryc_name))
	     [Mag_ParPS,index_PS]=unique(ScenarioProb.ParScenPS(:,2));
	     index_PS(length(index_PS)+1)=size(ScenarioProb.ParScenPS,1)+1;
	     for i=1:length(Mag_ParPS)
		 index_magnitude(i)=find(Mag_ParPS(i)==Magnitude);
	     end
          else
             lb_Mw=Param.Configure.Magnitude_lb; ub_Mw=Param.Configure.Magnitude_ub;
             lb_Mw=Mw-lb_Mw; ub_Mw=Mw+ub_Mw;   %%% Selection on the magnitude boundaries HERE
             index_magnitude=find(Magnitude>=lb_Mw & Magnitude<=ub_Mw);
	  end
    case ('Hazard')
        index_magnitude=1:length(Magnitude);
        index_magnitude=index_magnitude';
end

%% read mesh, cell barycenters and boundary of seismogenic zone and rigidity yes/no

% barycenters = centers of the triangles
% Spatial probabIlity of each scenario TO BE DONE if using for PTF (for Hazard)!

name_filemesh=strcat('../config_files/Mesh/',zone_code,'_mesh_15km.inp');
fid=fopen(name_filemesh); %Mesh file to be checked
[nodes,cells]=read_mesh_file(fid);
fclose(fid);
barycenters_all=find_barycenters(nodes,cells);
if Slab.Sub_boundary_logic
    name_bnd=strcat('../config_files/Mesh/',zone_code,'_boundary.txt');
    mesh_subbnd=readtable(name_bnd);
    bnd_mesh=[mesh_subbnd(:,1).Variables mesh_subbnd(:,2).Variables ,mesh_subbnd(:,3).Variables];
else
    bnd=boundary(nodes(:,1),nodes(:,2),1); 
    bnd_mesh=nodes(bnd,:);
end

if Stress_drop_logic
    for j=1:N_scaling
        V1=-(gamma2(1,j)+2*gamma1(1,j))/(gamma1(1,j)+gamma2(1,j));
        V2=-(gamma1(1,j)+2*gamma2(1,j))/(gamma1(1,j)+gamma2(1,j));
        exponent=(gamma1(1,j)+gamma2(1,j));
        exponent=exponent/(gamma1(1,j)*V1+gamma2(1,j)*V2-gamma1(1,j)-gamma2(1,j));
        [mu_all,mu_BL,mu_bal]=Assign_rigidity(-1e-3*barycenters_all(:,3),Fact_rigidity,exponent);
        Slab.fact_mu_z(j,:)=mu_bal./mu_BL; %factor to be used to balance stress drop through L/W and Area
        clear mu_BL V1 V2
    end
else
    mu_all=Assign_rigidity(-1e-3*barycenters_all(:,3),Fact_rigidity);
end

K_all=Coupling_pdf_CaA_function(1e-3*barycenters_all(:,3));    %Assign_coupling(1e-3*barycenters_all(:,3));
SPDF_all=K_all./mu_all; SPDF_all=SPDF_all/sum(SPDF_all);   % remove/put K_all in the first command to remove/put coupling
name_filemu=strcat('../config_files/Rigidity/mu_',zone_code,'.dat');
fid=fopen(name_filemu,'w');
fprintf(fid,'%.6f\n',[mu_all].');
fclose(fid);



%% Active barycenters for the whole subduction and selection of barycenters for case-study or hazard
min_bnd_dist=Param.Configure.minimum_bnd_distance;
int_dist=Param.Configure.minimum_interdistance;
hypo_baryc_dist=Param.Configure.hypo_baryc_distance;
if ~Preprocess_logic
    [p0,distanceJB]=compute_distance2fault2D(bnd_mesh(:,:),barycenters_all(:,:),Sub_boundary_logic,Merc_Zone,0);
    for i=1:length(Magnitude)
        for j=1:N_scaling % 1 Murotani - 2 Strasser
            index_active{i,j}=find(distanceJB>min_bnd_dist*Width_aux(i,j));
        end
    end
    Slab.index_active=index_active;
end


Slab.AreaSL=Area_aux; Slab.WidthSL=Width_aux; Slab.LengthSL=Length_aux; 
Slab.index_magnitude=index_magnitude;   Slab.bnd_mesh=bnd_mesh;
Slab.nodes=nodes; Slab.cells=cells; Slab.barycenters_all=barycenters_all;
Slab.int_dist=int_dist; Slab.hypo_baryc_dist=hypo_baryc_dist;

if Param.Configure.file_baryc==1
    Slab.index_PS=index_PS;
    barycenter=select_barycenter_from_file(Slab,ScenarioProb);
else
    [barycenter,ind_aux]=select_barycenter2(Slab);   % use select_barycenter2 for adaptive 
                                                 % barycenter sampling with
                                                 % magnitude (otherwise
                                                 % select_barycenter takes
                                                 % all the barycenters)
end
Slab.barycenter=barycenter;


%% Define rupturing area

[Area_tot,Area_cells] = compute_area(nodes,cells,Merc_Zone);
Area_tot=Area_tot*1e-6; Area_cells=Area_cells*1e-6;
Mesh_connect_file=strcat('../config_files/Connection_cell/EToE_',zone_code);
load(Mesh_connect_file);
Matrix_distance_file=strcat('../config_files/Matrix_distances/',zone_code,'_matrix_distance.bin');
fprintf('Loading Matrix of the distance\n\n')
%Matrix_distance=load(Matrix_distance_file);
fid=fopen(Matrix_distance_file);
Matrix_distance=fread(fid,[length(nodes) length(nodes)],'float');
fclose(fid);
%load(Matrix_distance_file);

Fact_Area=Param.Configure.Fact_area_scaling; Slab.Fact_Area=Fact_Area;
Slab.EtoE=EToE; Slab.Area_cells=Area_cells; Slab.Matrix_distance=Matrix_distance; 

fprintf('Rupture area computation\n')
for i=1:length(index_magnitude)
    fprintf('Magnitude bin # %d - Mw=%.4f \n',[i Magnitude(index_magnitude(i))])
    for j=1:N_scaling
        if ~isempty(barycenter{i,j})
	%	Slab.barycenter{i,j}=Slab.barycenter{i,j}(1);  %TO EVENTUALLY USE ONLY ONE SCENARIO
            Rupturing_areas(i,j).Event=Rupture_area_cells(Slab,i,j);
        else
            Rupturing_areas(i,j).Event=[];
        end
    end
end

%% Write Output
Write_output(Rupturing_areas,Magnitude,index_magnitude,SPDF_all,Name_scaling,Area_cells,namefolder)

%% generate folder tree for outputs
cd ..
cd (namefolder_slip)
mkdir('homogeneous_mu'); mkdir('variable_mu');
for i=1:length(index_magnitude)
    folder_magnitude=sprintf('%6.4f',Magnitude(index_magnitude(i)));
    folder_magnitude(2)='_';
    mkdir(strcat('homogeneous_mu/',folder_magnitude));
    mkdir(strcat('variable_mu/',folder_magnitude));
    for j=1:length(Name_scaling)
            mkdir(strcat('homogeneous_mu/',folder_magnitude,'/',Name_scaling{j}));
            mkdir(strcat('variable_mu/',folder_magnitude,'/',Name_scaling{j}))
    end
end
cd ..
fclose all;
t=toc;
return
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ mu,mu_BL,mu_bal ] = Assign_rigidity(depth,Fact_mu,exponent)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%%  Assign rigidity variation

PREM_mu=[ 0 26.5;3 26.5;15 43.9;24.4 67.8;40 67.6;60 67.3;80 64.6;115 64.2];

a = 0.5631; b = 0.0437; 
mu=zeros(length(depth),1);
mu_BL=zeros(length(depth),1);
%%% GEIST & BILEK RIGIDITY
%%% AVERAGE WITH PREM RIGIDITY
for i=1:length(depth)
    mu(i) = 10^(a + b*depth(i));
    mu_BL(i)=mu(i);
    for j=1:length(PREM_mu(:,1))-1
        if depth(i) >= PREM_mu(j,1) && depth(i) <= PREM_mu(j+1,1)
            rigidity_PREM(i) = linear_interp(depth(i),PREM_mu(j:j+1,:));
            break
        end
    end
    if  mu(i) >= rigidity_PREM(i)
        if depth(i)>10
            mu(i) = rigidity_PREM(i);
            mu_BL(i) = rigidity_PREM(i);
        end
    else
        mu(i) = Fact_mu*(mu(i) + rigidity_PREM(i));
    end
    %clear rigidity_PREM
end
if nargin==3
    [~,index]=min(abs(mu_BL'-rigidity_PREM));
    coeff=mu_BL(index)^(-1);
    mu_bal=coeff^(exponent).*mu_BL.^(exponent+1);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mu = linear_interp(depth,PREM)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
m = (log10(PREM(2,2))-log10(PREM(1,2)))/(PREM(2,1)-PREM(1,1));
q = log10(PREM(1,2)) - m*PREM(1,1);
mu = m*depth + q;
mu = 10^mu;
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
function [Area_tot,Area_cells] = compute_area(nodes,cells,Merc)

Area_tot=0;
Area_cells=zeros(length(cells),1);

[X,Y,zone_utm]=ll2utm(nodes(:,2),nodes(:,1),Merc);
if length(zone_utm)==length(X)
   Y(zone_utm<0)=Y(zone_utm<0)-max(Y);
end
nodes(:,1)=X; nodes(:,2)=Y;
%nodes(:,1:2)=ll2utm(nodes(:,2),nodes(:,1),Merc);

for i=1:length(cells)
    a=pdist([nodes(cells(i,1),:);nodes(cells(i,2),:)],'euclidean');
    b=pdist([nodes(cells(i,2),:);nodes(cells(i,3),:)],'euclidean');
    c=pdist([nodes(cells(i,3),:);nodes(cells(i,1),:)],'euclidean');
    per=0.5*(a+b+c);
    Area_cells(i)=sqrt(per*(per-a)*(per-b)*(per-c));
    Area_tot=Area_tot+Area_cells(i);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Write_output(Rupturing_areas,Magnitude,index_magnitude,SPDF_all,Name_scaling,Area_cells,namefolder)

    fprintf('Writing Output\n')
for i=1:length(index_magnitude)
    fprintf('Magnitude bin # %d - Mw=%.4f \n',[i Magnitude(index_magnitude(i))])
    Mo=10^(1.5*Magnitude(index_magnitude(i))+9.1);
    folder_magnitude=sprintf('%6.4f',Magnitude(index_magnitude(i)));
    folder_magnitude(2)='_';
    mkdir(folder_magnitude); cd(folder_magnitude);
    for j=1:length(Name_scaling)
        %if j==1
            mkdir(Name_scaling{j}); cd(Name_scaling{j});
        %else
        %    mkdir('Strasser'); cd('Strasser');
        %end
        for l=1:length(Rupturing_areas(i,j).Event)
            if Rupturing_areas(i,j).Event(l).true
            index_baryc=Rupturing_areas(i,j).Event(l).cell(1);
            filename = strcat('QuakeArea_',sprintf('%.5d',index_baryc),'.dat'); %Quake_Area_file
            fid=fopen(filename,'w');
            fprintf(fid,'%d\n',[Rupturing_areas(i,j).Event(l).cell'].');
            fclose(fid);
            % Slip_PDF file (used for variable rigidity)
            SPDF=SPDF_all(Rupturing_areas(i,j).Event(l).cell); SPDF=SPDF/sum(SPDF); SPDF=SPDF';
            %SPDF=ones(length(Rupturing_areas(i,j).Event(l).cell)); SPDF=SPDF/sum(SPDF); SPDF=SPDF';
            filename = strcat('Slip_PDF_',sprintf('%.5d',index_baryc),'.dat');
            fid=fopen(filename,'w');
            fprintf(fid,'%.6f\n',[SPDF].');
            fclose(fid);
            Area_event=sum(Area_cells(Rupturing_areas(i,j).Event(l).cell))*1e6;
            slip2file=Mo/(Area_event);
            filename = strcat('mu_Slip_aux_',sprintf('%.5d',index_baryc),'.dat');
            fid=fopen(filename,'w');
            fprintf(fid,'%.4f\n',slip2file);
            fclose(fid);    
            end
        end
        cd ..
    end
    cd ..
    movefile(folder_magnitude,strcat('../',namefolder));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function barycenter=select_barycenter(Slab)  
% Selects all the barycenters within a distance 
% from the hypocenter  


application=Slab.application; index_magnitude=Slab.index_magnitude;
index_active=Slab.index_active; barycenters_all=Slab.barycenters_all;
Length_aux=Slab.LengthSL; Magnitude=Slab.Magnitude; 
switch application
    case('PTF')  %Discrimination is the distance from the hypocenter 
        hypo_GEO=Slab.hypo_GEO;
        l=0;
        for i=index_magnitude'
            l=l+1;
            for j=1:2
                kk=1;
                for k=1:length(index_active{i,j})
                    Lon=[barycenters_all(index_active{i,j}(k),1) hypo_GEO(1)];
                    Lat=[barycenters_all(index_active{i,j}(k),2) hypo_GEO(2)];
                    if dist_wh(Lat,Lon)<Length_aux(i,j)*1e3  
                        barycenter{l,j}(kk)=index_active{i,j}(k);
                        kk=kk+1;
                    end
                end
                if kk==1
                    barycenter{l,j}=[];
                end
            end
        end
    case('Hazard')  % Discrimination is the distance from the active barycenter
        l=0;
        for i=index_magnitude'
            fprintf('Magnitude bin # %d - Mw=%.4f \n',[i Magniutde(i)])
            l=l+1;
            for j=1:2
                if i<=0
                    barycenter{l,j}=index_active{i,j};
                else
                    barycenter{l,j}(1)=index_active{i,j}(1);
                    kk=2;
                    for k=2:length(index_active{i,j})
                        for num=1:kk-1
                            Lon=[barycenters_all(index_active{i,j}(k),1) barycenters_all(barycenter{l,j}(num),1)];
                            Lat=[barycenters_all(index_active{i,j}(k),2) barycenters_all(barycenter{l,j}(num),2)];
                            dist_aux(num)=dist_wh(Lat,Lon);
                        end
                        if min(dist_aux)>0.05*Length_aux(i,j)*1e3
                            barycenter{l,j}(kk)=index_active{i,j}(k);
                            kk=kk+1;
                        end
                        clear dist_aux
                    end
                end
            end
        end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [barycenter,ind_aux]=select_barycenter2(Slab)
% Samples the barycenters depending on the mangitude 
% (the larger the magnitude the coarser the spacing, depending on the specific scaling relationship)
% Selects all the barycenters within a distance 
% from the hypocenter  


application=Slab.application; index_magnitude=Slab.index_magnitude;
barycenters_all=Slab.barycenters_all;
Length_aux=Slab.LengthSL; Magnitude=Slab.Magnitude;
Preprocess_logic=Slab.Preprocess_logic; zone_code=Slab.zone_code;
N_scaling=Slab.N_scaling; int_dist=Slab.int_dist; hypo_baryc_dist=Slab.hypo_baryc_dist;

if Preprocess_logic
    load(strcat('../config_files/Barycenters/ind_aux_full_',zone_code,'.mat'))
    for i=1:length(index_magnitude)
        for j=1:N_scaling
            ind_aux{i,j}=ind_aux_full{index_magnitude(i),j};
        end
    end
else
    index_active=Slab.index_active;
    l=0;
    fprintf('Barycenter selection\n')
    for i=index_magnitude'
            fprintf('Magnitude bin # %d - Mw=%.4f \n',[i Magnitude(i)])
            l=l+1;
            for j=1:N_scaling
                if isempty(index_active{i,j})
                    barycenter{l,j}=index_active{i,j};
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
        clear barycenter;
end        
        
switch application
    case('PTF')  %Discrimination is the distance from the hypocenter 
        hypo_GEO=Slab.hypo_GEO;
        l=0;
        fprintf('Barycenter selection\n')
        for i=1:size(ind_aux,1)	
            fprintf('Magnitude bin # %d - Mw=%.4f \n',[i Magnitude(index_magnitude(i))])
            l=l+1;
            for j=1:N_scaling
                kk=1;
                for k=1:length(ind_aux{i,j})
                    Lon=[barycenters_all(ind_aux{i,j}(k),1) hypo_GEO(1)];
                    Lat=[barycenters_all(ind_aux{i,j}(k),2) hypo_GEO(2)];
                    if dist_wh(Lat,Lon)<hypo_baryc_dist*Length_aux(index_magnitude(i),j)*1e3  % for Gareth application
                        barycenter{l,j}(kk)=ind_aux{i,j}(k);
                        kk=kk+1;
                    end
                end
                if kk==1
                    barycenter{l,j}=[];
                end
            end
        end
    case('Hazard')  % Discrimination is the distance from the active barycenter
        barycenter=ind_aux;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function barycenter=select_barycenter_from_file(Slab,ScenarioProb)
index=Slab.index_PS; index_magnitude=Slab.index_magnitude; N_scaling=Slab.N_scaling; 
barycenters_all=Slab.barycenters_all; Magnitude=Slab.Magnitude;
index(length(index)+1)=size(ScenarioProb.ParScenPS,1)+1;
k_index=ones(length(index_magnitude),N_scaling);
fprintf('Barycenter selection\n')
for i=1:length(index_magnitude)
    fprintf('Magnitude bin # %d - Mw=%.4f \n',[i Magnitude(index_magnitude(i))])
    for j=index(i):index(i+1)-1
        if ScenarioProb.ParScenPS(j,6)==0 || ScenarioProb.ParScenPS(j,6)==1 
	   if ScenarioProb.ParScenPS(j,5)==1
              ind_sc=2;
	      barycenter{i,ind_sc}(k_index(i,ind_sc))=find(abs(barycenters_all(:,1)-ScenarioProb.ParScenPS(j,3))<1e-3 & abs(barycenters_all(:,2)-ScenarioProb.ParScenPS(j,4))<1e-3);
              k_index(i,ind_sc)=k_index(i,ind_sc)+1;
	   elseif ScenarioProb.ParScenPS(j,5)==3
              ind_sc=1;
	      barycenter{i,ind_sc}(k_index(i,ind_sc))=find(abs(barycenters_all(:,1)-ScenarioProb.ParScenPS(j,3))<1e-3 & abs(barycenters_all(:,2)-ScenarioProb.ParScenPS(j,4))<1e-3);
	      k_index(i,ind_sc)=k_index(i,ind_sc)+1;
           end
        end
     end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [K]=Assign_coupling(depth)

x=[min(depth) max(depth)];
K=zeros(length(depth),1);
%% make a parabolyc
V=[x(1)+7 1];
P=[x(1)-1 0];
B=[-V(1)^2 1 V(2); P(1)^2-P(1)*2*V(1) 1 P(2)];
B_aux=rref(B);
a=B_aux(1,3); b =-a*2*V(1); c =B_aux(2,3);

%%
A_pow=[(x(end)-7)^7 1 1;x(end)^7 1 0];
coeff_pow=rref(A_pow);
a_pow=coeff_pow(1,3); b_pow=coeff_pow(2,3);
a_d=-0.046004756242568; b_d=a_d*32; c_d=-10.777217598097508;
 
for i=1:length(depth)
    depth_aux=depth(i);
    if depth_aux<=x(1)+7.
        K(i)=a*depth_aux^2+b*depth_aux+c;
    elseif depth_aux>x(1)+7 && depth_aux<=x(end)-7
        K(i)=1;
    %elseif depth_aux>x(end)-7 && depth_aux<x(end)-4
     %   K(i)=a_d*depth_aux^2+b_d*depth_aux+c_d;
    else
        K(i)=a_pow*depth_aux^7+b_pow;
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [K]=Coupling_pdf_CaA_function(depth)



%x=(-49.084:0.1:-3.9816);
%x=load('CaA_Depth.txt');

%x = -x/1000;
%% make a parabolyc
V=[-40. 1];
P=[-50. 0];

B=[-V(1)^2 1 V(2); P(1)^2-P(1)*2*V(1) 1 P(2)];
B_aux=rref(B);

a=B_aux(1,3); b =-a*2*V(1); c =B_aux(2,3);

%%

A_pow=[-13^7 1 1;-3.9816^7 1 0];
coeff_pow=rref(A_pow);
a_pow=coeff_pow(1,3); b_pow=coeff_pow(2,3);

%% parabolyc shallow link

V=[-14.5 1];
P=[-12. a_pow*(-12)^7+b_pow];

B=[-V(1)^2 1 V(2); P(1)^2-P(1)*2*V(1) 1 P(2)];
B_aux=rref(B);

a_d=B_aux(1,3); b_d =-a_d*2*V(1); c_d =B_aux(2,3);

%a_d=-0.046004756242568; b_d=a_d*32; c_d=-10.777217598097508;
 

%%
%depth=-depth;
for i=1:length(depth)
    if depth(i)<=-40
%         K=a_lin*depth+b_lin;
%     elseif depth>-40 && depth<=-30
        K(i)=a*depth(i)^2+b*depth(i)+c;
    elseif depth(i)>-40 && depth(i)<=-14.5
        K(i)=1;
    elseif depth(i)>-14.5 && depth(i)<-12.
        K(i)=a_d*depth(i)^2+b_d*depth(i)+c_d;
    else
        K(i)=a_pow*depth(i)^7+b_pow;
    end

    if K(i)<0
        K(i)=0.;
    end
end
end
