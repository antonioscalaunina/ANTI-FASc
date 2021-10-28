The preprocess consists of two steps:

   - A mesh generator: it either generates a triangular mesh from a distribution of fault points (Lat,Lon,Depth) or simply generate a mesh*.inp file from a pre-defined discretization of the domain. It also defines files containing the faces connection and the nodes interdistances, putting them in relative folders within the *config_files* directory. It can be run either running the MATLAB script *create_mesh_file.m*, e.g. typing in linux terminal the following command:

    matlab -nodisplay -nosplash -nodesktop -r "run('create_mesh_file.m'); exit;"
    
or, alternatively, with the installation of a MATLAB Runtime running the compiled standalone executable:

    ./run_create_mesh_file.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
   
For more details about the installation and use of MATLAB Runtime refer to the webpage:

    https://www.mathworks.com/products/compiler/matlab-runtime.html
    
    
 - A rupture barycenters selection: it performs an optimised selection of the rupture areas barycenter based on the magnitude and geometry size expected from the prescribed scaling law. This selection will minimize in the rupture areas computation the number of rupture areas with high level of similarity.
