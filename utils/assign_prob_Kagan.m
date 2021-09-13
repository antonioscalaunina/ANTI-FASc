function [Prob,G] = assign_prob_Kagan(Magnitude)


%Input Magnitude contains the magnitude bin as given in the project

Momento_sis = 10.^(1.5.*Magnitude+9.1); %Seismic moment array
beta = 0.639; %beta from Kagan
mc = 8.75; %Corner magnitude from Kagan
Mom_mc = 10^(1.5*mc+9.1); % Corner seismic moment

G = (Momento_sis(1)./Momento_sis).^(beta);
G=G.*exp((Momento_sis(1)-Momento_sis)/Mom_mc); %Computation of G (equation 2 from Kagan)


%% G is a Cumulative Distribution Function; 
%% to extract the probability from each interval we extract (from the last to the first point)
%% the probability within each bin as G(i) - G(i+1);

Prob(length(G)) = G(end);
for i=length(G)-1:-1:1
Prob(i) = G(i) - G(i+1);
end


% figure
% loglog(Momento_sis,G,'LineWidth',2)
% grid on
% set(gca,'FontSize',22)
% xlabel ('Seismic Moment (N \cdot m)')
% ylabel ('G(M,M_t,\beta,M_c)')
% title ('Kagan CDF')
% 
% figure
% semilogy(Magnitude,Prob,'bo','MarkerSize',8,'MarkerFaceColor','b'); %'LineWidth',2)
% grid on
% set(gca,'FontSize',22)
% xlabel ('Magnitude')
% ylabel ('G(M,M_t,\beta,M_c)')
% title ('Conditioned probability of exceedance')
% 
% figure
% loglog(Momento_sis,Prob,'LineWidth',2)
% grid on
% set(gca,'FontSize',22)
% xlabel ('Seismic Moment (N \cdot m)')
% ylabel ('G(M,M_t,\beta,M_c)')
% title ('Kagan-based PDF')
% 
% figure
% semilogy(Magnitude,Prob,'LineWidth',2)
% grid on
% set(gca,'FontSize',22)
% xlabel ('Magnitude')
% ylabel ('G(M,M_t,\beta,M_c)')
% title ('Kagan-based PDF')
end

