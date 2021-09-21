# EXAMPLE 1 Tohoku

In this brief guide we describe the instructions to install all the necessary components to run ANTI-FASc and a practical example.
All the instructions have been tested on the OS Ubuntu20.04. The procedure consists of 4 phases: Installation, Preprocess, Rupture Areas and Slip Distribution, Postprocess

- INSTALLATION:

First, if you don't have, install gfortran typing:

    sudo apt-get install gfortran
    
and git typing

    sudo apt-get install git
    
It could also be useful to install git-lfs

    sudo apt-get install git-lfs

This will allow you to download the whole package of the code, including all the configuration files already computed and distributed in the config_file/ subdfolders

To donwload the code you can either download the zip archive from the web-page: (this option does not download all the precomputed configuration files However you can create 
them on your own, see PREPROCESS section of this guide) 

    https://github.com/antonioscalaunina/ANTI-FASc
    
or typing:

    git clone https://github.com/antonioscalaunina/ANTI-FASc.git.
    
For some linux distributions it could be necessary to type:

    git-lfs clone https://github.com/antonioscalaunina/ANTI-FASc.git
    
to download all the precomputed configuration files.
Once downloaded the package, you may need to change permission for *.sh* files. In the main directory type:

    sudo chmod -R u+x *.sh

The MATLAB modules of the platform can be run either installing a licensed version (MATLAB R2020a or newer) or installing a MATLAB Runtime (MATLAB Runtime R2020a or newer) for free.
The released versions and the instructions for installations can be found at: 

    https://www.mathworks.com/products/compiler/matlab-runtime.html
    
    
-  PREPROCESS

In this example we generate slip distributions compatible with the estimated magnitude and location of the Mw 9.1 Tohoku earthquake (2011-03-11). 
In the preprocess part we firstly generate a mesh defined on the Kurils-Japan slab geometry defined by the project Slab 2.0 and available at the web-page:

    https://www.sciencebase.gov/catalog/item/5aa4060de4b0b1c392eaaee2
    
ANTI-FASc can work by using both the *_dep*.xyz and the *_dep*.grd file that you can download here. These two files, for this example are already available in the folder utils/sz_slabs/

The mesh generation will be managed through the configuration set in the file *config_files/Parameters/input.json*:

    {"zone_name": "kurilsjapan2",    #Name chosen by the user, arbitrary
        "Merc_zone": 54,             #Mercator Zone
    "acronym": "KJ2",                #Acronym - it will be used to generate and use all the configuration files all the process long
        "mesh_gen": 1,               # 1 means that a new mesh should be generated
    "slab_file": "kur_slab2_dep_02.24.18.xyz",    #name of the Slab 2.0 file
    "seismog_depth": 60,            #Max depth included in the mesh
    "element_size": 12.5e3,         #Average size of mesh face

    "Event": {
    "Name": "Tohoku",               # Name for the event
    "Hypo_LonLat" : [142.369, 38.322],   #Fixed epicenter
    "Magnitude" : 9.0                    #Fixed magnitude
    },
    "Configure": {
    "application": "PTF",
    "shape": "Rectangle",
    "numb_stoch": 5,                     # Number of stochastic slip for each rupture areas
    "variable_mu": 1,                    # 1 means that also the distributions with variable rigidity have to be computed
    "Magnitude_lb": 0.15,                # Magnitude in a range [Mw-0.15 Mw+0.15] will be accounted
    "Magnitude_ub": 0.15,
    "hypo_baryc_distance": 1.0,          # Rupture barycenters at less than 1 Length (inferred from scaling law for each Magnitude bin) form hypocenter will be accounted

move into the preprocess folder:

    cd preprocess
    
If you have a licensed version of MATLAB run the script *create_mesh_file.m*.
Properly adding matlab command to your .bashrc file you can also run from the terminal typing:

    matlab -nodisplay -nosplash -nodesktop -r "run('create_mesh_file.m'); exit;"
    
Alternatively, if you have installed MATLAB runtime, type:

    ./run_create_mesh_file.sh /usr/local/MATLAB/MATLAB_Runtime/v99
    
The second step will create some importante configuration files containing the interdistances between all the grid nodes, type the following commands:

    cd matrix_connection_gen
    make clean
    make
    ./input_conn.x
    
Finally the last script will generate a selection of rupture barycenters having a fixed minimum interdistance, optimised to avoid to have too much similar rupture areas, in particular for large magnitude bins. This selection is based on the magnitude binning and the selected scaling laws that are set in the file *config_files/Parameters/scaling_relationships.json*. In this example we used a selection similar to that one proposed for TSUMAPS-NEAM (see Basili et al. 2021) using the Strasser et al. (2010) and the Murotani et al.(2013) scaling relationship. You can either run this part from the MATLAB interface with the script *ind_baryc_pre.m* or typing:

     matlab -nodisplay -nosplash -nodesktop -r "run('ind_baryc_pre.m'); exit;"
     
Alternatively, with the MATLAB Runtime you can digit:

    ./run_ind_baryc_pre.sh /usr/local/MATLAB/MATLAB_Runtime/v99
    

- RUPTURE AREAS AND SLIP DISTRIBUTIONS 

In the folder bin run the script for the Rupture area computation, that is the MATLAB script *Rupture_areas_OF.m*

it can be also run typing:

    matlab -nodisplay -nosplash -nodesktop -r "run('Rupture_areas_OF.m'); exit;"
    
or, alternatively (with MATLAB Runtime)

    ./run_Rupture_areas_OF.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    
Finally with the following commands you run the slip distribution computation:

     cd ../src/k223d/
     make clean
     make
     cd ../
     ./src/bash_scripts/run_homo.sh    # To compute slip distributions with uniform rigidity
     ./src/bash_scripts/run_var.sh     # To compute slip distributions with variable rigidity
     
 # POSTPROCESSING
 
 The output will be organized as shown in the following tree:
 
     output/
    └── Tohoku_M90_E14237_N3832_slip
    ├── homogeneous_mu
    │   ├── 8_8846
    │   │   ├── Murotani
    │   │   │   ├── KJ2_mesh_15km.inp
    │   │   │   ├── Slip4HySea00001_001.dat
    │   │   │   ├── Slip4HySea00001_002.dat
    │   │   │   ├── Slip4HySea00001_003.dat
    │   │   │   ├── Slip4HySea00001_004.dat
    │   │   │   ├── Slip4HySea00001_005.dat
    │   │   │   ├── Slip4HySea00003_001.dat
    │   │   │   ├── Slip4HySea00003_002.dat
    │   │   │   ├── Slip4HySea00003_003.dat
    │   │   │   ├── Slip4HySea00003_004.dat
    │   │   │   ├── Slip4HySea00003_005.dat
    │   │   │   ├── Slip4HySea00005_001.dat
    │   │   │   ├── Slip4HySea00005_002.dat
    │   │   │   ├── Slip4HySea00005_003.dat
    │   │   │   ├── Slip4HySea00005_004.dat
    │   │   │   ├── Slip4HySea00005_005.dat
    │   │   │   ├── Slip4HySea00007_001.dat
    │   │   │   ├── Slip4HySea00007_002.dat
    │   │   │   ├── Slip4HySea00007_003.dat
    │   │   │   ├── Slip4HySea00007_004.dat
    │   │   │   ├── Slip4HySea00007_005.dat
    .......................................
 
 
    


    
