function Event=Rupture_area_cells(Slab,i,j)


EToE=Slab.EtoE; Area_cells=Slab.Area_cells; AreaSL=Slab.AreaSL; WidthSL=Slab.WidthSL; 
index_magnitude=Slab.index_magnitude;  barycenter=Slab.barycenter; Nodes=Slab.nodes; Cells=Slab.cells;
Matrix_distance=Slab.Matrix_distance; shape=Slab.shape; Fact_Area=Slab.Fact_Area;


fact_mu_z=ones(size(Area_cells));
exponent_scaling=1;

if Slab.Stress_drop_logic
    gamma1=Slab.gamma1; gamma2=Slab.gamma2; sum_gamma=gamma1+gamma2;
    exponent_scaling=(0.5*(gamma2)/sum_gamma);
    fact_mu_z=Slab.fact_mu_z;
end

Event(length(barycenter{i,j}),1) = struct('cell',[]);

for l=1:length(barycenter{i,j})
    Event(l).true=true;
    Area_event = 0;
    ng = 1;
    Event(l).cell(ng) = barycenter{i,j}(l);
    fact_LWA = fact_mu_z(barycenter{i,j}(l));   %To be checked for a stress drop case
    Event(l).nodes4events(1:3,1) = Cells(Event(l).cell(ng),:);
    ng=ng+1;
    k=2; k_nodes=4;
    Area_event = Area_cells(barycenter{i,j}(l));
    get_out=0;
    while(get_out==0)
        for jj=1:3
            if(EToE(Event(l).cell(ng-1),jj)~=0)
                index_cell = find(Event(l).cell(1:k-1)==EToE(Event(l).cell(ng-1),jj),1);
                if isempty(index_cell) 
                    Event(l).cell(k) = EToE(Event(l).cell(ng-1),jj);
                    if Slab.Sub_boundary_logic
                        in=inpolygon(Slab.barycenters_all(Event(l).cell(k),1),...
                            Slab.barycenters_all(Event(l).cell(k),2),...
                            Slab.bnd_mesh(:,1),Slab.bnd_mesh(:,2));
                    else
                        in = logical(true);
                    end   
                        if in
                            Event(l).nodes4events(k_nodes:k_nodes+2,1) = Cells(Event(l).cell(k),:);
                            %Check on the width to keep the aspect ratio
                            depth4event=Nodes(Event(l).nodes4events,3);
                            [max_depth,ind_max_depth]=min(depth4event);
                            [min_depth,ind_min_depth]=max(depth4event);
                            distance=1.e-3*Matrix_distance(Event(l).nodes4events(ind_max_depth),...
                            Event(l).nodes4events(ind_min_depth));
                            switch shape
                                case('Circle')
                                    k=k+1; k_nodes=k_nodes+3;
                                    Area_event = Area_event + Area_cells(EToE(Event(l).cell(ng-1),jj));
                                case('Rectangle')
                                    if distance<max([1.1*sqrt(Fact_Area)*...
                                            ((fact_LWA)^exponent_scaling)...
                                            *WidthSL(index_magnitude(i),j),50])
                                        k=k+1; k_nodes=k_nodes+3;
                                        Area_event = Area_event + Area_cells(EToE(Event(l).cell(ng-1),jj));
                                    end
                            end
                        end
                    
                            
                end
            end
            
            if Area_event > Fact_Area*sqrt(fact_LWA)*AreaSL(index_magnitude(i),j)   %
                get_out=1;
            break
            elseif jj==3
                ng = ng+1;
            if  ng-1>k  || ng-1>size(Slab.barycenters_all,1)  || ng-1 > size(Event(l).cell,2)
                %
                Event(l).true = false;
                %disp('False event')
                get_out=1;
            end
            end
        end  
    end
end


% for i=1:size(Cells,1)
%     if event_true(i)
%         filename_c = strcat('QuakeArea_',sprintf('%.4d',i),'.dat');
%         filename_n = strcat('QuakeArea_',sprintf('%.4d',i),'.txt');
%         fid_c=fopen(filename_c,'w');
%         fid_n=fopen(filename_n,'w');
%         for j=1:length(Event(i).cell)
%             fprintf(fid_c,'%d\n',Event(i).cell(j));
%             index_node = find(Cells==Event(i).cell(j),1);
%             for k=1:3
%                 fprintf(fid_n,'%f %f %f\n',[Nodes((index_node-1)*3+k,1) Nodes((index_node-1)*3+k,2) Nodes((index_node-1)*3+k,3)]);
%             end
%         end
%     end
%     fclose (fid_c); fclose(fid_n);
end
    


