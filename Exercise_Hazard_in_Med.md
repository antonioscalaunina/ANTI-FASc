# EXERCISE - Slip distribution for hazard in Mediterranean

Now you should be ready to create your ensemble properly setting your choices in the input files.

For this exercise let's create an ensemble for one slab in the Mediterranean basin: Calabrian Arc, Hellenic Arc or Cyprus Arc.

If you want to run the whole workflow starting from the mesh generation you can set the magnitude binning and the scaling relationship as you prefer in the file *config_files/Parameters/scaling_relationship.json*. 
Otherwise if you want to run directly the Rupture areas and slip distribution modules you must use the same file used for the Example of Makran with the following commands:

    cd config_files/Parameters
    cp scaling_relationship_Makran.json scaling_relationship.json

Then you can create the mesh either from the nodes/cells discretization already available in the folder *utils/sz_slabs* or importing the file from the Slab webpage (See details in [Example1](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/Example1_Tohoku.md) )
