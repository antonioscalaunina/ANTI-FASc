In this brief guide we describe the insturctions to install all the necessary components to run ANTI-FASc and a practical example.
All the instructions have been tested on the OS Ubuntu20.04

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

The MATLAB modules of the platform can be run either installing a licensed version (MATLAB R2020a or newer) or installing a MATLAB Runtime (MATLAB Runtime R2020a or newer) for free.
The released versions and the instructions for installations can be found at: 

    https://www.mathworks.com/products/compiler/matlab-runtime.html
    
    
-  PREPROCESS

In this example we generate slip distributions compatible with the estimated magnitude and location of the Mw 9.1 Tohoku earthquake (2011-03-11). 
In the preprocess part we firstly generate a mesh defined on the Kurils-Japan slab geometry defined by the project Slab 2.0 and available at the web-page:

    https://www.sciencebase.gov/catalog/item/5aa4060de4b0b1c392eaaee2
    
ANTI-FASc can work by using both the *_dep*.xyz and the *_dep*.grd file that you can download here. These two files, for this example are already available in the folder utils/sz_slabs/
