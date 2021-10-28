The preprocess consists of two steps:

   - A mesh generator: it either generates a triangular mesh from a distribution of fault points (Lat,Lon,Depth) or simply generate a mesh*.inp file from a pre-defined discretization of the domain. It also defines files containing the faces connection and the nodes interdistances, putting them in relative folders within the *config_files* directory. It can be run either running the MATLAB script *create_mesh_file.m*, e.g. typing in linux terminal the following command:

    matlab -nodisplay -nosplash -nodesktop -r "run('create_mesh_file.m'); exit;"      # if you have a licensed version of MATLAB
    
or, alternatively, with the installation of a MATLAB Runtime running the compiled standalone executable:

    ./run_create_mesh_file.sh /usr/local/MATLAB/MATLAB_Runtime/v99/      # if you download, for free, the MATLAB Runtime
   
For more details about the installation and use of MATLAB Runtime refer to the webpage:     
    
    https://www.mathworks.com/products/compiler/matlab-runtime.html
    
    
 - A rupture barycenters selection: it performs an optimised selection of the rupture areas barycenter based on the magnitude and geometry size expected from the prescribed scaling law. This selection will minimize in the rupture areas computation the number of rupture areas with high level of similarity. It can be run changing the folder

    cd barycenter_selection
    
 and running the MATLAB script *ind_baryc_pre.m*. In Linux enviroment this script can be run again with the two possible options:
 
    matlab -nodisplay -nosplash -nodesktop -r "run('ind_baryc_pre.m'); exit;"    # if you have a licensed version of MATLAB

or:

    ./run_ind_baryc_pre.sh /usr/local/MATLAB/MATLAB_Runtime/v99/    # if you download, for free, the MATLAB Runtime
    

The two described scripts import input information from the files *config_files/Parameters/input.json* and *config_files/Parameters/scaling_relationship.json*. More details about the preparation of these files can be found in the examples presented in the main folder.

These scripts also make use:
 - the script *textprogressbar.m* available at *https://it.mathworks.com/matlabcentral/fileexchange/55285-textprogressbar*. This script is redistributed in this distribution along with its copyright and licence notice.
 - the scripts *utm2ll.m* and *ll2utm.m* available at *https://it.mathworks.com/matlabcentral/fileexchange/45699-ll2utm-and-utm2ll*. These scripts are redistributed in this distribution along with their copyright and licence notice. (See within the folder *src/Rupture_areas/*)
 - the script *dist_wh.m* available in the github repository *Beamform* at *https://github.com/lsxinh/Beamform/dist_wh*
 - the script *tiConnect_2D.m* available in the github repository *nodal_dg* at *https://github.com/tcew/nodal-dg/tree/master/Codes1.1/Codes2D/tiConnect_2D.m*. This script is redistributed in this distribution along with its copyright and licence notice.
