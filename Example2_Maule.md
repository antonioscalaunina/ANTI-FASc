# EXAMPLE 2 Maule earthquake

The second example will generate slip distributions based on the location and magnitude of the M8.8 Maule earthquake occurred on the south-american slab on the 2010-02-27.

The procedure is very similar to the previous example and you only need to change some of the settings in the *config_files/Parameters/input.json* file.
From the available files on this repository you can simply change the "main" input file as follow:

    cd config_files/Parameters
    mv input.json input_Tohoku.json  #to keep the input file for the Tohoku example
    mv input_Maule.json input.json.
    
The new *input.json* file will appear as:

    {"zone_name": "southamerica2",
        "Merc_zone": 18,
    "acronym": "SA2",
        "mesh_gen": 1,
    "slab_file": "sam_slab2_dep_02.23.18.xyz",
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
    
The needed files (*sam_slab2_dep_02.23.18.xyz* or *sam_slab2_dep_02.23.18.grd*) can be downloaded from the Slab 2.0 website. For this example they are already included in the folder *utils/sz_slabs*

Now:

    cd matrix_connection_gen
    make clean
    make
    ./input_conn.x
    
and finally run the script *ind_baryc_pre.m*

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
    
   
