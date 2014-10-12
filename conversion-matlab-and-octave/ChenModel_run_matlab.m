% Test code for the model of the combined calcium + granule compartments,
% as per Yi-der Chen, Shaokun Wang, and Arthur Sherman,
% doi:10.1529/biophysj.107.124990

% See code in the derivative function to learn about the 
% interpretation of the state vector.


% Integrate
x_0=ChenModelInit();
[t,x]=ode15s('ChenModel',[0 60],x_0);

%% Plot of cumulative secretion (quick test)
plot(t,x(:,11));

%% Resample on 1-min time basis (to lag)
t_min=0:60;
SE_res=interp1(t,x(:,11),t_min);
plot(t_min,SE_res);

%% Average secretion, i.e., tau=2 min
% measured=4.5*(SE - delay(SE, tau));
N=length(SE_res);
measured=4.5*(SE_res(3:N)-SE_res(1:(N-2)));

plot(measured,'o-');
xlabel 'Time, min';
ylabel 'ISR, pg/islet/min';

%% Figure 2
% Change ton=toff=8/60 in membrane

x_0=ChenModelInit();
[t,x]=ode15s('ChenModel',[0 48/60],x_0);

subplot(211);
plot(t*60,x(:,1));
box off;
set(gca,'FontSize',18);
ylabel('Cmd, \mu M');
subplot(212);
plot(t*60,x(:,2));
box off;
set(gca,'FontSize',18);
ylabel('Ci, \mu M');
xlabel('Time, sec');
% saveas(gcf,'Figure2.eps');
% !convert -trim -density 150 Figure2.eps Figure2.gif

% To do:  
%  - figures
%  - separate parameters such as GlucFact and input wave

