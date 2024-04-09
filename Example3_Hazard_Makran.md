Example3_Hazard_Makran.md

The magnitude bins and the rupture geometries (according to the selected scaling laws) are set in the input file *config_files/Parameters/scaling_relationship.json* described below. In this example we use a selection similar to that one proposed in the framework of the project TSUMAPS-NEAM (see Basili et al. 2021) using the Strasser et al. (2010) and the Murotani et al.(2013) scaling relationships. See comments beside:

    { 
    "Magnitude_bins": {                                     # Within this section the number of magnitude bins and the magnitude bins are defined
    "number_bins" : 32, 
    "Magnitude": [6.0000, 6.5000, 6.8012, 7.0737, 7.3203, 7.5435, 7.7453, 7.9280, 8.0933,
              8.2429, 8.3782, 8.5007, 8.6115, 8.7118, 8.8025, 8.8846, 8.9588, 9.0260, 
	      9.0869, 9.1419, 9.1917, 9.2367, 9.2775, 9.3144, 9.3478, 9.3780, 9.4053, 
	      9.4300, 9.4524 , 9.4727, 9.4910,9.5075]
    },

    "Scaling_law": { "number": 2,                            # Here we declare the number of different scaling laws used in the code        
    "name" : ["Murotani", "Strasser"],                       # Names of scaling laws (must be consistent with the selected number
    "Area": [156.233, 494.051, 988.488, 1851.277, 3266.416, 5460.991, 8691.034, 13236.448,                         #Values of the area. They must be "number_bins" * "number" (of Scaling law). In this case the first 32 refer to Murotani scaling law, while the remaining one to the Strasser scaling
	          19367.407, 27332.004, 37322.564, 49484.760, 63866.258,  80458.414, 99145.149,
	          119776.459, 142092.603, 165871.385, 190821.652, 216599.421, 242912.949, 
	          269467.272, 295988.071, 322227.910, 347970.147, 373030.811, 397258.801, 
	          420534.777, 442769.108, 463899.186, 483886.383, 502712.864,
        172.187, 515.229, 997.108, 1812.018, 3111.183, 5074.719, 7898.154, 11788.431, 
	          16936.419, 23509.360, 31626.155, 41368.179, 52740.956, 65710.323, 80164.115, 
	      	  95970.819, 112921.750, 130843.454, 149515.800, 168684.550, 188138.900, 207668.823, 
		  227081.948, 246207.279, 264897.303, 283028.731, 300502.136, 317240.766, 333188.779, 
		  348309.117, 362581.201, 375998.580],
    "Length": [10.2770, 20.7196, 31.6095, 46.3198, 65.4563, 89.5107, 118.7881, 153.4749, 193.5108,                #Values of the length. They must be "number_bins" * "number" (of Scaling law). In this case the first 32 refer to Murotani scaling law, while the remaining one to the Strasser scaling. The Width W will be computed for each bin as Area/Length
                    238.6781, 288.5428, 342.6192, 400.2115, 460.6512, 523.1286, 586.9580,
                    651.3207, 715.6812, 779.437, 841.965, 902.856, 961.739, 
		    1018.321, 1072.384, 1123.771, 1172.388, 1218.190, 
		    1261.171, 1301.370, 1338.847, 1373.687, 1405.992,
           10.789, 21.159, 31.747, 45.826, 63.882, 86.287, 113.240, 144.837, 180.959, 
                    221.359, 265.612, 313.263, 363.687, 416.297, 470.395, 525.401, 580.628, 
		    635.638,689.940, 743.025, 794.570, 844.286, 891.947, 937.387, 980.496, 
		    1021.208, 1059.502, 1095.388, 1128.905, 1160.116, 1189.101, 1215.950]
 
    }
    }


To start the preprocess run, move into the preprocess folder:

    cd preprocess
    
If you have a licensed version of MATLAB run the script *create_mesh_file.m*.

Properly adding matlab command to your .bashrc file you can also run it from the terminal typing:

    matlab -nodisplay -nosplash -nodesktop -r "run('create_mesh_file.m'); exit;"
    
Alternatively, if you have installed MATLAB runtime, type:

    ./run_create_mesh_file.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    
It has been verified that in some Ubuntu versions for the WSL distributions you may need to type (also valid for the other MATLAB compiled scripts):

    sh run_create_mesh_file.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
    
The second step will generate a selection of rupture barycenters having a fixed minimum interdistance (as mentioned in description of *input.json* file. This distance is optimised to avoid to have too much similar rupture areas, in particular for large magnitude values. This selection is based on the magnitude binning and the selected scaling laws that are set in the file *scaling_relationships.json*. After changing directory:
    
    cd barycenter_selection
    
You can either run this part from the MATLAB interface with the script *ind_baryc_pre.m* or typing:
    
    matlab -nodisplay -nosplash -nodesktop -r "run('ind_baryc_pre.m'); exit;"
     
Alternatively, with the MATLAB Runtime you can type:

    ./run_ind_baryc_pre.sh /usr/local/MATLAB/MATLAB_Runtime/v99/

This step is the longest of the whole process and may take several minutes (until hours on some personal computers). However, once it is run, the barycenter selection is stored and can be always used for other tests based on the same magnitude binning and scaling relationship selection over the same mesh discretization.
    

# 3 - Rupture areas and slip distributions 

To start the computation of the rupture areas, in the folder *bin/*, run the MATLAB script *Rupture_areas_OF.m*

it can be also run typing:

    matlab -nodisplay -nosplash -nodesktop -r "run('Rupture_areas_OF.m'); exit;"
    
or, alternatively (with MATLAB Runtime):

    ./run_Rupture_areas_OF.sh /usr/local/MATLAB/MATLAB_Runtime/v99/

This module makes use the same input parameters previously described and will create for each selected barycenter a *QuakeArea* file containing the cells actually rupturing for that particular simulation. More details about the generation of these files and the folder system can be found in the [Wiki](https://github.com/antonioscalaunina/ANTI-FASc/wiki) documentation
    
Finally with the following commands you might run the slip distributions computation. For each rupture area from the previous step a number of slip distribution is computed as indicated in the file *input.json*

     cd ../src/k223d/       # Compiling the k223d.f90 module
     make clean
     make
     mv k223d.x ../../bin                 # moving the executable in the bin folder
     cd ../..
     ./src/bash_scripts/run_homo.sh    # To compute the slip distribution ensemble with uniform rigidity
     ./src/bash_scripts/run_var.sh     # To compute slip distributions ensemble with variable rigidity
     
 # 4 - Postprocessing
 
 The output will be finally organized as shown in the following tree:
 
     output/
    └── Tohoku_M90_E14237_N3832_slip    #Name of events + Magnitude + Location + _slip
    ├── homogeneous_mu                  #Rigidity
    │   ├── 8_8846                      #Magnitude
    │   │   ├── Murotani                #Scaling law
    │   │   │   ├── KJ2_mesh_15km.inp   #Mesh
    │   │   │   ├── Slip4HySea00001_001.dat    #Slip distributions
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

It is important to notice that at the moment a predefined rake=90° is imposed. Next versions of the code will implement the possibility of impose different (possibly varying) rake angles.
    
 They can be easily plotted by simple personal scripts. In the folder *utils* there is the script *slip_distribution_plot_AGI.m*. As for all the MATLAB scripts, this one can be run either in the MATLAB command window or with one of the following commands:
 
    matlab -nodisplay -nosplash -nodesktop -r "run('slip_distribution_plot_AGI.m'); exit;" 
    
 
    ./run_slip_distribution_plot_AGI.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
     
This script will ask which class of scenario (which magnitude and scaling law) you would like to plot and will save the *.png* plots in the corresponding *output* folder
    


    
