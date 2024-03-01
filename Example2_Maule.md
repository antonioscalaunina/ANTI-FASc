# EXAMPLE 2 Maule earthquake

The second example will generate slip distributions based on the location and magnitude of the M8.8 Maule earthquake occurred on the south-american slab on the 2010-02-27.

In this example the mesh generation is skipped and the precomputed mesh and input baryceneter files are used.

The procedure is very similar to the previous example and you only need to change some of the settings in the *config_files/Parameters/input.json* file.
From the available files on this repository you can simply change the "main" input file as follow:

    cd config_files/Parameters
    cp input_Maule.json input.json
    
The new *input.json* file will appear as (check the meaning of the parameters in the example 1:

    {"zone_name": "southamerica",
        "Merc_zone": 18,
    "acronym": "SoA",
        "mesh_gen": 0,
    "slab_file": "[]",
    "seismog_depth": 60,
    "depth_interpolator": "nearest",
    "mesh_convex": 0.3,
    "element_size": 12.5e3,

    "Event": {
    "Name": "Maule",
    "Hypo_LonLat" : [-72.71, -35.85],
    "Magnitude" : 8.8
    },
    "Configure": {
    "application": "PTF",
    "shape": "Rectangle",
    "numb_stoch": 5,
    "variable_mu": 1,
    ...............................................
    
From now on the step will be fully similar to the "Tohoku" example

#  1 - Preprocess

Enter in the preprocess folder

    cd preprocess

and run from MATLAB command window the script create_mesh_file.m

Of course, also in this case, you can run it from terminal typing:

    matlab -nodisplay -nosplash -nodesktop -r "run('create_mesh_file.m'); exit;"

or (if you have installed the MATLAB runtime)

    ./run_create_mesh_file.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    
The Slab 2.0 files (*sam_slab2_dep_02.23.18.xyz* or *sam_slab2_dep_02.23.18.grd*) are also included in the folder *utils/sz_slabs*. Nevertheless, they won't be used. In the folder *utils/sz_slabs/* a database of precomputed mesh is available. In particular this example makes use the southamerica folder

    alaskaaleutians   hjort                 manokwari         outerrise_kermadectonga  sangihe             timor
    arutrough         izumariana            manus             outerrise_puysegur       sangihe_backthrust  timortrough
    banda_detachment  japan                 mexico            outerrisenewhebrides     se_sulawesi         tolo_thrust
    calabrian         kermadectonga2        moresby_trough    outerrisesolomon         seram_thrust        trobriand
    cascadia          kurils                mussau            outerrisesunda           seramsouth
    cyprus            kurilsjapan           newguinea2        philippine               solomon2
    flores            macquarieislandnorth  newhebrides2      puysegur2                southamerica
    floreswetar       macquarienorth        north_sulawesi    ryuku                    sunda2
    hellenic          makran2               outer_rise_timor  sandwich                 tanimbar

Now:
    
    cd barycenter_selection/

And then:

    matlab -nodisplay -nosplash -nodesktop -r "run('ind_baryc_pre.m'); exit;"
    
or:

    ./run_ind_baryc_pre.sh /usr/local/MATLAB/MATLAB_Runtime/v99/


    
# 3 - Rupture areas and slip distributions

Now, to run the rupture areas computation

    mv ../../bin
    
And execute the script *Rupture_areas_OF.m*

With also the usual two possibilities:

    matlab -nodisplay -nosplash -nodesktop -r "run('Rupture_areas_OF.m'); exit;"
    
or:

    ./run_Rupture_areas_OF.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    
The slip distributions are computed through the code k223d

    cd ../src/k223d/
    make clean
    make
    mv k223d.x ../../bin
    cd ../..
    ./src/bash_scripts/run_homo.sh    # To compute slip distributions with uniform rigidity
    ./src/bash_scripts/run_var.sh     # To compute slip distributions with variable rigidity
    
    
# 4 - Postprocessing

Finally as already described in the Example 1 - Tohoku, you can obtain the plots of the slip distributions through the script *utils/slip_distribution_plot_AGI.m* 

    matlab -nodisplay -nosplash -nodesktop -r "run('slip_distribution_plot_AGI.m'); exit;" 

or:

    ./run_slip_distribution_plot_AGI.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    
# 5 - Use of available mesh dataset

To use the available dataset you must download the complete repository that is available only at the following DOI: https://zenodo.org/doi/10.5281/zenodo.10625118.
Within this repository, all the available meshes (config_files/Mesh) and connection matrices (config_files/Matrix_distances) can be downloaded.

In the folder *utils/sz_slabs/* a database of precomputed mesh is available:

    alaskaaleutians   hjort                 manokwari         outerrise_kermadectonga  sangihe             timor
    arutrough         izumariana            manus             outerrise_puysegur       sangihe_backthrust  timortrough
    banda_detachment  japan                 mexico            outerrisenewhebrides     se_sulawesi         tolo_thrust
    calabrian         kermadectonga2        moresby_trough    outerrisesolomon         seram_thrust        trobriand
    cascadia          kurils                mussau            outerrisesunda           seramsouth
    cyprus            kurilsjapan           newguinea2        philippine               solomon2
    flores            macquarieislandnorth  newhebrides2      puysegur2                southamerica
    floreswetar       macquarienorth        north_sulawesi    ryuku                    sunda2
    hellenic          makran2               outer_rise_timor  sandwich                 tanimbar
    
Changing some of the settings in the file *config_files/Parameters/input.json* as follows:

    {"zone_name": "southamerica",
        "Merc_zone": 18,
        "acronym": "SA1",
        "mesh_gen": 0,
     ...........................
     "Event": {
     "Name": "Maule_other_mesh",
     "Hypo_LonLat" : [-72.71, -35.85],
     "Magnitude" : 8.8
     },
     ..................................
     
you can run the whole procedure skipping the mesh generation. Please take into account that you have to run also the *create_mesh_file.m* step. In this configuration the script only writes the precomputed mesh in the right format:
 
Basically, in the *input.json* file you should:
1 - choose a zone name between the folder names above
2 - impose the corresponding Merc Zone (suggestions for the precomputed mesh are in the file *config_files/slab_database*)
3 - choose a three letter acronym (possible different from the analogous example with mesh generation to avoid to overwrite the configuration files)
4 - impose the mesh_gen to 0
5 - Impose a different Event.Name (to not overwrite the final output folder).


    
  
