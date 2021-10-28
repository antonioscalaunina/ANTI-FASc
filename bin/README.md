The *Rupture_areas_OF* generates rupture areas, according to prescribed magnitude-size scaling, starting from a barycenter selection over the selected fault surface.
It can either use the precomputed barycenter selection from the preprocess module *ind_baryc_pre.m* or define this selection on-the-fly during the run. This latter procedure, however, significantly enlarge the computational time.

It can work in two modes:

 - Hazard: it computes all the possible different rupture areas (according to the previous barycenters selection) in the prescribed magnitude bins

 - PTF: it computes all the scenarios “compatible” with estimation and uncertainty of magnitude and location for a given earthquake

It can be run either launching the MATLAB script *Rupture_areas_OF.m*, e.g., from a linux terminal typing the command:

    matlab -nodisplay -nosplash -nodesktop -r "run('Rupture_areas_OF.m'); exit;"    # if you have a licensed version of MATLAB
    
or, alternatively, by using the compiled standalone executable as follows:

    ./run_Rupture_areas_OF.sh /usr/local/MATLAB/MATLAB_Runtime/v99/     #If you have installed MATLAB Runtime
    
This code import input information from several configuration files. The files *Parameters/input.json* and *Parameters/scaling_relationship.json* must be set by the user. The input files in the folders *Barycenters*, *Connection_cell*, *Mesh* and *Matrix_distances* are defined in the preprocess part (for more details about these files see the examples in the main folder)
