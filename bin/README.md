The module named *Rupture_areas_OF* generates rupture areas, according to prescribed magnitude-size scaling, starting from a barycenter selection over the selected fault surface.
It can either use the precomputed barycenter selection from the preprocess module *ind_baryc_pre.m* or define this selection on-the-fly during the run. This latter mode, however, significantly enlarge the computational time.

The nodule can work in two modes:

 - Hazard: it computes all the possible different rupture areas (according to the previous barycenters selection) in the prescribed magnitude bins

 - PTF: it computes all the scenarios “compatible” with estimation and uncertainty of magnitude and location for a given earthquake. In this case the user must set a range around the estimated magnitude and location. The module also allows to use a precompiled selection of magnitude and rupture areas computed through the software matPT available at *https://github.com/INGV/matPTF* (Selva et al. 2021) 

It can be run either launching the MATLAB script *Rupture_areas_OF.m*, e.g. from a linux terminal typing the command:

    matlab -nodisplay -nosplash -nodesktop -r "run('Rupture_areas_OF.m'); exit;"    # if you have a licensed version of MATLAB
    
or, alternatively, by using the compiled standalone executable as follows:

    ./run_Rupture_areas_OF.sh /usr/local/MATLAB/MATLAB_Runtime/v99/     #If you have installed MATLAB Runtime
    
This code import input information from several configuration files. The files *Parameters/input.json* and *Parameters/scaling_relationship.json* must be set by the user. The input files in the folders *Barycenters*, *Connection_cell*, *Mesh* and *Matrix_distances* must be computed in the preprocess module (for more details about these files see the examples in the main folder)

This module also makes use:

 - the scripts utm2ll.m and ll2utm.m available at https://it.mathworks.com/matlabcentral/fileexchange/45699-ll2utm-and-utm2ll. These scripts are redistributed in this distribution along with their copyright and licence notice. (See within the folder src/Rupture_areas/)
 - the script dist_wh.m available in the github repository Beamform at https://github.com/lsxinh/Beamform/blob/master/dist_wh.m

BIBILIOGRAPHY

Selva, J., Lorito, S., Volpe, M. et al. (2021). Probabilistic tsunami forecasting for early warning. Nat Commun 12, 5677 (2021). DOI: 10.1038/s41467-021-25815-w
