# EXAMPLE 3 Makran hazard
In this guided example, we described a different application. Given a mesh, we define an ensemble of slip distributions which represent an almost homogeneous 
coverage of the whole seismogenic area. In this view, the ensemble can be used for the Probablistic Tsunami Hazard Assessment (PTHA), or as a precmputed ensemble to
extract the needed scenario for PTF application (see Basili et al. 2021 and Selva et al. 2021 [bibliography here](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/README.md) )

# 1 - Installation

If you have already run the first two examples you should have installed all the requirments. Otherwise please follow the instructions [here](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/Example1_Tohoku.md)

# 2 - Preprocess

To run this example you should copy the input_Makran.json into the standard input.json file

    cp input_Makran.json input.json

And just as example, we used a simplified magnitude binning (only 18 bins between Mw 6.0 and Mw 9.0) and only one scaling relationship (Strasser). To use this simplified version

    cp scaling_relationship_Makran.json scaling_relationship.json

The preprocess steps might be skipped for this applications exploiting the already available files stored in the folder *config_files*. 
However with the following *input.json* and *scaling_relationship.json* files you can also run the whole workflow starting from the preprocess steps:

**input.json**

            {"zone_name": "makran2",    # If the user want to skip the preprocess phase this name should be the corresponding folder name in this [file](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/config_files/slabs_database)
            "Merc_zone": 41,            # Select the proper Mercator Zone from this [file](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/config_files/slabs_database)
            "acronym": "MaK",           # Select the right acronym from this [file](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/config_files/slabs_database)
            "mesh_gen": 0,              # 0 means that the pre-computed mesh discretization [here](https://github.com/antonioscalaunina/ANTI-FASc/tree/main/utils/sz_slabs) will be used
            "slab_file": "kur_slab2_dep_02.24.18.xyz",    # NOT USED if "mesh_gen": 0
            "seismog_depth": 60,            # NOT USED if "mesh_gen": 0
            "depth_interpolator": "v4"      # NOT USED if "mesh_gen": 0
            "mesh_convex": 0.5              # NOT USED if "mesh_gen": 0 
            "element_size": 12.5e3,         # NOT USED if "mesh_gen": 0

            "Event": {                     #  if "application": "Hazard" only the "Name" info will be used vut to generate a compatible folder name for the output
            "Name": "Makran_Hazard",                    # Name for the folder in output
            "Hypo_LonLat" : [142.369, 38.322],   # NOT USED if "application": "Hazard"
            "Magnitude" : 9.0                    # NOT USED if "application": "Hazard"
                    },
            "Configure": {
            "application": "Hazard",             # This application set the computation of a whole ensemble (within the selected magnitude binning) to be used for PTHA applications.   
            "shape": "Rectangle",                # This choice allows to compute scenarios with aspect ratio L/W preserved. The other possible choice is "Circle". More details in the Wiki documentation (under construction)
            "numb_stoch": 5,                     # Number of stochastic slip for each rupture areas
            "variable_mu": 1,                    # 1 means that also the distributions with variable rigidity have to be computed
            "Magnitude_lb": 0.15,                # NOT USED if "application": "Hazard"
            "Magnitude_ub": 0.15,                # NOT USED if "application": "Hazard"
            "hypo_baryc_distance": 1.0,          # NOT USED if preprocess is skipped, but this was the used option for precomputed files
            "minimum_bnd_distance": 0.25,        # NOT USED if preprocess is skipped, but this was the used option for precomputed files
            "minimum_interdistance": 0.1,        # NOT USED if preprocess is skipped, but this was the used option for precomputed files
            "Fact_area_scaling": 1,              # With this choice generate rupture areas having exactly the size expected from the selected scaling relationship are computed
            "Rigidity_file_logic": 1,            # A rigidity profile with depth set by the user is selected
            "Rigidity_file": "Rigidity_variation.txt", # Name of the rigidity profile file. This example file can be found [here](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/config_files/Parameters/Rigidity_variation.txt)
            "Stress_drop_var": 0,                # No stress drop variation is imposed among scenarios
            "Fact_rigidity": 0.5                 # If "Rigidity_file_logic": 0 a rigidity variation similar to what proposed by Scala et al. 2020 is imposed. This choice uses at each depth an intermediate value between the Bilek & Lay (1999) variation and PREM is                                                             imposed. See Scala et al. (2020) and the Wiki documentation for more details

**scaling_relationship.json**

            { 
            "Magnitude_bins": {
            "number_bins" : 18, 
            "Magnitude": [6.0000, 6.5000, 6.8012, 7.0737, 7.3203, 7.5435, 7.7453, 7.9280, 8.0933,
              8.2429, 8.3782, 8.5007, 8.6115, 8.7118, 8.8025, 8.8846, 8.9588, 9.0260]
            },

            "Scaling_law": { "number": 1,
            "name" : ["Strasser"],
            "Area": [172.187, 515.229, 997.108, 1812.018, 3111.183, 5074.719, 7898.154, 11788.431, 
	                          16936.419, 23509.360, 31626.155, 41368.179, 52740.956, 65710.323, 80164.115, 
	      	                  95970.819, 112921.750, 130843.454],
            "Length": [10.789, 21.159, 31.747, 45.826, 63.882, 86.287, 113.240, 144.837, 180.959, 
                                221.359, 265.612, 313.263, 363.687, 416.297, 470.395, 525.401, 580.628, 
		                    635.638]
 
            }
            }


# 3 - Rupture areas and slip distributions 

As for the previous examples, to start the computation of the rupture areas, in the folder *bin/*, run the MATLAB script *Rupture_areas_OF.m*

it can be also run typing:

    matlab -nodisplay -nosplash -nodesktop -r "run('Rupture_areas_OF.m'); exit;"
    
or, alternatively (with MATLAB Runtime):

    ./run_Rupture_areas_OF.sh /usr/local/MATLAB/MATLAB_Runtime/v99/

    
and with the following commands you might run the slip distributions computation. For each rupture area from the previous step a number of slip distribution is computed as indicated in the file *input.json*

     cd ../src/k223d/       # Compiling the k223d.f90 module
     make clean
     make
     mv k223d.x ../../bin                 # moving the executable in the bin folder
     cd ../..
     ./src/bash_scripts/run_homo.sh    # To compute the slip distribution ensemble with uniform rigidity
     ./src/bash_scripts/run_var.sh     # To compute slip distributions ensemble with variable rigidity

 # 4 - Postprocessing
 
 The folder tree of the outputs and the standard format of the outputs is described in the [Example1](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/Example1_Tohoku.md)

    
The script *slip_distribution_plot_AGI.m* in the folder *utils* can be still used to plot some of the slip distributions. As for all the MATLAB scripts, this one can be run either in the MATLAB command window or with one of the following commands:
 
    matlab -nodisplay -nosplash -nodesktop -r "run('slip_distribution_plot_AGI.m'); exit;" 

or alternatively,
 
    ./run_slip_distribution_plot_AGI.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
     
This script will ask which class of scenario (which magnitude and scaling law) you would like to plot and will save the *.png* plots in the corresponding *output* folder.

Also the python script [plot_slip_distribution.py](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/utils/plot_slip_distribution.py) can be used for the same goal. It will produce for the selected folders the slip distributions in standard geoJSON format and interactive maps in HTML format

