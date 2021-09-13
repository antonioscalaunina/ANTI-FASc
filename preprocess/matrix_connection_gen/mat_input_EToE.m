clc
clear all
close all
disp('Saving Element to Element connection file')
fid=fopen('param_zone_input.dat');
fgetl(fid); zone_code=fgetl(fid);
fclose(fid);
filename=strcat('EToE_',zone_code,'.mat');
load('EToE.dat');
for i=1:size(EToE,1)
    for j=1:size(EToE,2)
        if EToE(i,j)==i
            EToE(i,j)=0;
        end
    end
end
save(filename,'EToE');
