# EXAMPLE 1 Tohoku earthquake

In this brief guide, we describe the instructions to install all the necessary requirements to run ANTI-FASc along with a practical example.
All the instructions have been tested on the OS Ubuntu20.04. The procedure consists of 4 phases: Installation, Preprocess, Rupture Areas and Slip Distribution, Postprocess

# 1 - Installation

First, if you don't have, please install gfortran typing:

    sudo apt-get install gfortran
    
and git typing:

    sudo apt-get install git
    
It could also be useful to install git-lfs:

    sudo apt-get install software-properties-common
    sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install git-lfs
    git lfs install

git-lfs will allow you to download the whole package of the code that also includes some pre-computed configuration files distributed in the *config_files/* subdfolders

To donwload the code you can either download the zip archive from the following web-page: (this option does not download all the precomputed configuration files, however you can create them on your own. Moreover, to run the following example the configuration files database is not necessary, see PREPROCESS section of this guide) 

    https://github.com/antonioscalaunina/ANTI-FASc
    
or typing:

    git clone https://github.com/antonioscalaunina/ANTI-FASc.git
    
For some linux distributions it could be necessary to type:

    git-lfs clone https://github.com/antonioscalaunina/ANTI-FASc.git
    
to download all the precomputed configuration files.

Once downloaded the package, on your personal computer and within the main folder, you may need to give all the permissions to read and execute all the files. Please type:

    cd ANTI-FASc
    sudo chmod -R ugo+rwx *

The MATLAB modules of the platform can be run either installing a licensed version (MATLAB R2020a or newer) or installing for free a MATLAB Runtime (MATLAB Runtime R2020a or newer).
The released versions and the instructions for installations of MATLAB-Runtime can be found at: 

    https://www.mathworks.com/products/compiler/matlab-runtime.html
    
    
# 2 - Preprocess

In this example we generate slip distributions compatible with the estimated magnitude and location of the Mw 9.0 Tohoku earthquake (2011-03-11). 
In the preprocess part we firstly generate a mesh defined on the Kurils-Japan slab geometry. This has been defined in the framework of the project Slab 2.0 and is available at the web-page:

    https://www.sciencebase.gov/catalog/item/5aa4060de4b0b1c392eaaee2
    
Other slab models can be found at:

    https://www.sciencebase.gov/catalog/item/5aa1b00ee4b0b1c392e86467
    
    
ANTI-FASc mesh generator can work by using both the *_dep*.xyz and the *_dep*.grd file that you can download here. These two files, for this example are already available in the folder *utils/sz_slabs/*

The mesh generation will be managed through the configuration set in the file *config_files/Parameters/input.json*.

Look carefully at the comments beside the parameters IN PARTICULAR FOR THE PARAMETERS "depth_interpolator" and "mesh_convex"

    {"zone_name": "kurilsjapan2",    #Name chosen by the user, arbitrary
        "Merc_zone": 54,             #Mercator Zone
    "acronym": "KJ2",                #Acronym (THREE DIGITS!) - it will be used to generate and use all the configuration files all the process long
        "mesh_gen": 1,               # 1 means that a new mesh should be generated
    "slab_file": "kur_slab2_dep_02.24.18.xyz",    #name of the Slab 2.0 file
    "seismog_depth": 60,            #Max depth included in the mesh
    "depth_interpolator": "v4"      # Algorithm of interpolation between Slab and grid nodes depth. "v4" is the suggested option but it could not work depending on MATLAB configuration. In this case change with "nearest"
    "mesh_convex": 0.5              # Mesh convexity: defined in the range [0 1]. 0 convex hull mesh boundary - 1 tightest single-region boundary. Use always values <= 0.5. Sometimes mesh generation might produce error about the non-uniqueness of face ID due to the concavity of mesh boundary: in that case, please slightly decrease "mesh_convex" 
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


To start the preprocess run, move into the preprocess folder:

    cd preprocess
    
If you have a licensed version of MATLAB run the script *create_mesh_file.m*.

Properly adding matlab command to your .bashrc file you can also run it from the terminal typing:

    matlab -nodisplay -nosplash -nodesktop -r "run('create_mesh_file.m'); exit;"
    
Alternatively, if you have installed MATLAB runtime, type:

    ./run_create_mesh_file.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    
It has been verified that in some Ubuntu versions for the WSL distributions you may need to type (also valid for the other MATLAB compiled scripts):

    sh run_create_mesh_file.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    
The second step will generate a selection of rupture barycenters having a fixed minimum interdistance. This distance is optimised to avoid to have too much similar rupture areas, in particular for large magnitude values. This selection is based on the magnitude binning and the selected scaling laws that are set in the file *config_files/Parameters/scaling_relationships.json*. In this example we use a selection similar to that one proposed in the framework of the project TSUMAPS-NEAM (see Basili et al. 2021) using the Strasser et al. (2010) and the Murotani et al.(2013) scaling relationships. After changing directory: 
    
    cd barycenter_selection
    
You can either run this part from the MATLAB interface with the script *ind_baryc_pre.m* or typing:
    
    matlab -nodisplay -nosplash -nodesktop -r "run('ind_baryc_pre.m'); exit;"
     
Alternatively, with the MATLAB Runtime you can type:

    ./run_ind_baryc_pre.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    

# 3 - Rupture areas and slip distributions 

To start the computation of the rupture areas, in the folder *bin/*, run the MATLAB script *Rupture_areas_OF.m*

it can be also run typing:

    matlab -nodisplay -nosplash -nodesktop -r "run('Rupture_areas_OF.m'); exit;"
    
or, alternatively (with MATLAB Runtime):

    ./run_Rupture_areas_OF.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    
Finally with the following commands you run the slip distributions computation:

     cd ../src/k223d/
     make clean
     make
     mv k223d.x ../../bin
     cd ../..
     ./src/bash_scripts/run_homo.sh    # To compute slip distributions with uniform rigidity
     ./src/bash_scripts/run_var.sh     # To compute slip distributions with variable rigidity
     
 # 4 - Postprocessing
 
 The output will be organized as shown in the following tree:
 
     output/
    ????????? Tohoku_M90_E14237_N3832_slip    #Name of events + Magnitude + Location + _slip
    ????????? homogeneous_mu                  #Rigidity
    ??????? ????????? 8_8846                      #Magnitude
    ??????? ??????? ????????? Murotani                #Scaling law
    ??????? ??????? ??????? ????????? KJ2_mesh_15km.inp   #Mesh
    ??????? ??????? ??????? ????????? Slip4HySea00001_001.dat    #Slip distributions
    ??????? ??????? ??????? ????????? Slip4HySea00001_002.dat
    ??????? ??????? ??????? ????????? Slip4HySea00001_003.dat
    ??????? ??????? ??????? ????????? Slip4HySea00001_004.dat
    ??????? ??????? ??????? ????????? Slip4HySea00001_005.dat
    ??????? ??????? ??????? ????????? Slip4HySea00003_001.dat
    ??????? ??????? ??????? ????????? Slip4HySea00003_002.dat
    ??????? ??????? ??????? ????????? Slip4HySea00003_003.dat
    ??????? ??????? ??????? ????????? Slip4HySea00003_004.dat
    ??????? ??????? ??????? ????????? Slip4HySea00003_005.dat
    ??????? ??????? ??????? ????????? Slip4HySea00005_001.dat
    ??????? ??????? ??????? ????????? Slip4HySea00005_002.dat
    ??????? ??????? ??????? ????????? Slip4HySea00005_003.dat
    ??????? ??????? ??????? ????????? Slip4HySea00005_004.dat
    ??????? ??????? ??????? ????????? Slip4HySea00005_005.dat
    ??????? ??????? ??????? ????????? Slip4HySea00007_001.dat
    ??????? ??????? ??????? ????????? Slip4HySea00007_002.dat
    ??????? ??????? ??????? ????????? Slip4HySea00007_003.dat
    ??????? ??????? ??????? ????????? Slip4HySea00007_004.dat
    ??????? ??????? ??????? ????????? Slip4HySea00007_005.dat
    .......................................
 
 The Slip4HySea* files are in the standard format used as input by the software Tsunami-HySea (https://edanya.uma.es/hysea/):
 
      LON1     LAT1    DEPTH1(km)      LON2    LAT2    DEPTH2(km)      LON3    LAT3    DEPTH3(km)      RAKE    SLIP(m)
    142.790939   36.904644   17.916529  142.853439   36.786213   16.508039  142.949966   36.886333   16.052090   90.000000   15.071705
    143.045685   36.982624   15.542809  142.949966   36.886333   16.052090  143.103119   36.871231   14.452849   90.000000   10.217474
    143.184433   36.964371   14.104160  143.045685   36.982624   15.542809  143.103119   36.871231   14.452849   90.000000    7.264385
    143.257324   37.034969   13.712790  143.140564   37.082138   15.023360  143.184433   36.964371   14.104160   90.000000    5.831795
    143.140564   37.082138   15.023360  143.257324   37.034969   13.712790  143.280243   37.123096   13.827730   90.000000    5.801642
    143.187408   37.199860   15.021840  143.280243   37.123096   13.827730  143.326065   37.221413   13.737390   90.000000    8.239328
    143.237747   37.307362   14.902081  143.326065   37.221413   13.737390  143.375885   37.321331   13.582370   90.000000    8.787484
    143.288528   37.406792   14.714769  143.375885   37.321331   13.582370  143.425613   37.421227   13.397850   90.000000    8.625984
    143.337967   37.506516   14.512549  143.425613   37.421227   13.397850  143.473877   37.525276   13.210250   90.000000    9.356437
    143.384659   37.620220   14.349310  143.473877   37.525276   13.210250  143.522858   37.629070   12.988800   90.000000    9.731079
    143.284637   37.707848   15.666740  143.384659   37.620220   14.349310  143.445618   37.743267   14.031441   90.000000   20.665806
    143.172379   37.784977   17.201698  143.284637   37.707848   15.666740  143.315338   37.826794   15.648809   90.000000   26.219276
    143.060059   37.862545   18.871019  143.172379   37.784977   17.201698  143.191238   37.904606   17.327589   90.000000   25.318876
    143.060059   37.862545   18.871019  143.191238   37.904606   17.327589  143.067352   37.977760   19.145472   90.000000   24.058483
    142.473907   38.087746   29.206949  142.514374   37.983589   27.932550  142.614288   38.076675   26.574770   90.000000   18.332708
    ..................................................................................................................................
    
 They can be easily plotted by simple personal scripts. In the folder *utils* there is the script *slip_distribution_plot_AGI.m*. As for all the MATLAB scripts, this one can be run either in the MATLAB command window or with one of the following commands:
 
    matlab -nodisplay -nosplash -nodesktop -r "run('slip_distribution_plot_AGI.m'); exit;" 
    
 
    ./run_slip_distribution_plot_AGI.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
     
This script will ask which class of scenario (which magnitude and scaling law) you will to plot and will save the *.png* plots in the corresponding *output* folder
    


    
