function [nodes,cells,string1,string2,string3] = read_mesh_file(fid)
% Read file mesh in the variable fid in inp format providing as nodes
% (Lon-Lat-Depth) and the cells (node indices of the vertices)
% the 

for i=1:9
    fgetl(fid);
end

for i=1:100000
    line=fgetl(fid);
    if line(1)=='*'
        numb_nodes=i-1;
        break
    end
end

for i=1:2
    fgetl(fid);
end

for i=1:100000
    line=fgetl(fid);
    if line(1)=='*'
        numb_cells=i-1;
        break
    end
end

frewind(fid);
nodes=zeros(numb_nodes,3); cells=zeros(numb_cells,3);

for i=1:9
    string1{i}=fgetl(fid);
end

for i=1:numb_nodes
    line=fgetl(fid);
    temp=str2num(line);
    ind_nod(i)=i;
    nodes(i,:)=temp(2:4);
end

for i=1:3
    string2{i}=fgetl(fid);
end

for i=1:numb_cells
    line=fgetl(fid);
    temp=str2num(line);
    ind_cell(i)=i;
    cells(i,:)=int16(temp(2:4));
end

if nargout>2
    for i=1:44
        string3{i}=fgetl(fid);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


