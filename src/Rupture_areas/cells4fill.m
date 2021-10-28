function [cells_mesh]=cells4fill(nodes_ll,nodes_d,cells)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(cells(:,1))
    cells_mesh(i).nodes(1:3,1)=nodes_ll(cells(i,:)+1,1);
    cells_mesh(i).nodes(1:3,2)=nodes_ll(cells(i,:)+1,2);
    cells_mesh(i).nodes(1:3,3)=nodes_d(cells(i,:)+1);
    cells_mesh(i).nodes(4,:)=cells_mesh(i).nodes(1,:);
end

