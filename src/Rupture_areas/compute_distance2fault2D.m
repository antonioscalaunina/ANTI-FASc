function [p0,distanceJB] =compute_distance2fault2D(fault,stations,logic_sbnd,Merc,logic_plot)

fault_UTM(:,1:2)=ll2utm(fault(:,2),fault(:,1),Merc); fault_UTM(:,3)=fault(:,3); 
stations_UTM=ll2utm(stations(:,2),stations(:,1),Merc);  stations_UTM(:,3)=stations(:,3);
p0=zeros(size(stations,1),2); distanceJB=zeros(size(stations,1),1); logic_stations=zeros(size(stations,1),1);

if logic_sbnd
    index=inpolygon(stations(:,1),stations(:,2),fault(:,1),fault(:,2));
    logic_stations(index)=1;
else
    logic_stations(:)=1;
end

if logic_plot
    figure(1000)
    plot(fault_UTM(:,1),fault_UTM(:,2))
    hold on
end


for i=1:length(stations)
    if logic_stations(i)
        depth_station=stations_UTM(i,3)*1.e-3;
        p0_aux=zeros(4,2); dist_aux=zeros(4,1);
        for j=1:length(fault_UTM)-1
            [p0_aux(j,:),dist_aux(j)]=find_closest_point_segment(fault_UTM(j:j+1,1:2),stations_UTM(i,1:2));
        end
        [distanceJB(i),index_p0]=min(dist_aux*1.e-3);
        depth_fault=fault_UTM(index_p0(1),3)*1e-3; %0.5*(fault_UTM(j,3)+fault_UTM(j+1,3))*1.e-3; 
        distanceJB(i)=sqrt(distanceJB(i)^2+(depth_fault-depth_station)^2);
        clear depth_fault
        p0(i,:)=p0_aux(index_p0,:);
        if logic_plot
            figure(1000)
            plot([stations_UTM(i,1),p0(i,1)],[stations_UTM(i,2),p0(i,2)],'k')
        end
        clear p0_aux dist_aux depth_station
    end
end
