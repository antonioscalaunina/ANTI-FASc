#!/bin/bash

#matlab -nodisplay -nosplash -nodesktop -r "run('bin/Rupture_areas_OF.m'); exit;"
#./run_Rupture_areas_OF.sh /usr/local/MATLAB/MATLAB_Runtime/v99/
cd ../src/k223d
make clean
make
mv k223d.x ../../bin/
cd ../../
folder=`sed -n 1"p" name_folders_file.dat`
folder_out=`sed -n 2"p" name_folders_file.dat`
mkdir $folder
mv bin/?_???? $folder
#mv $folder/6_* .
#mv $folder/7_0* .
sh src/bash_scripts/create_folders.sh
#rm index_file.dat
./src/bash_scripts/run_homo.sh
./src/bash_scripts/run_var.sh
mkdir input output
mv $folder_out output
mv $folder input
rm Magnitude_ev *.txt index_scenario input_magnitude *.dat
