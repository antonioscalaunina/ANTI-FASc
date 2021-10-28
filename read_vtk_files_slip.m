function [str_lines,nodes,cells,slip] = read_vtk_files_slip(fid)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i=1:5
      str_lines{i} = fgetl(fid);
end
  
numb_nodes = str2num(str_lines{5}(7:20));
nodes = zeros(numb_nodes,3);

for i=1:numb_nodes
    nodes(i,:) = str2num(fgetl(fid));
end

str_lines{6} = fgetl(fid);
numb_cells = str2num(str_lines{6}(9:23));
cells = zeros(numb_cells,3);

for i=1:numb_cells
    cells_aux = str2num(fgetl(fid));
    cells(i,:) = cells_aux(2:4);
end

for i=1:4
    fgetl(fid);
end

for i=1:numb_cells
    slip(i) = str2num(fgetl(fid));
end


end

