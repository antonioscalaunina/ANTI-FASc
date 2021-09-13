function [p,dist]  = find_closest_point_segment(segment,q)

p1=segment(1,:); 
p2=segment(2,:);
u=p2-p1;
norm(u);
%a=n(1); b=n(2); c=n(3); d=dot(n,v1);  %plane
for i=1:size(q,1)
    i;
    v=q(i,:)-p1;
    check=(dot(u,v)/norm(u)^2);
    if check>=0 && check<=1
        p(i,:)=p1+check*u;
    elseif check < 0
        p(i,:)=p1;
    else
        p(i,:)=p2;
    end
    dist(i)=norm(q-p);
end
end