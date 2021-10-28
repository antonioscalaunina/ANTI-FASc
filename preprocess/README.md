The preprocess consists of two steps:

   - A mesh generator: it either generates a triangular mesh from a distribution of fault points (Lat,Lon,Depth) or simply generate a mesh*.inp file from a pre-defined discretization of the domain. It also defines files containing the faces connection and the nodes interdistances, putting them in relative folders within the *config_files* directory. It can be run either running the MATLAB script *create_mesh_file.m*, e.g. typing in linux terminal the following command:

     matlab -nodisplay -nosplash -nodesktop -r "run('create_mesh_file.m'); exit;"
   
