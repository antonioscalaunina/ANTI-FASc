#!/bin/bash

matlab -nodisplay -nosplash -nodesktop -r "run('create_mesh_file.m'); exit;"
mv *mesh*.inp matrix_connection_gen
cd matrix_connection_gen
make clean
make
./input_conn.x
matlab -nodisplay -nosplash -nodesktop -r "run('mat_input_EToE.m'); run('ind_baryc_pre.m'); exit;"
rm EToE.dat
mv ETo*.mat *mesh*.inp *matrix* ind_aux* barycenters_all* ../
cd ../
mv ETo*.mat ../config_files/Connection_cell
mv *mesh*.inp ../config_files/Mesh
mv *matrix_distance.bin ../config_files/Matrix_distances
mv ind_aux* barycenters_all* ../config_files/Barycenters
