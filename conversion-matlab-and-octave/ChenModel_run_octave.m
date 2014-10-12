% Test code for the model of the combined calcium + granule compartments,
% as per Yi-der Chen, Shaokun Wang, and Arthur Sherman,
% doi:10.1529/biophysj.107.124990

% See code in the derivative function to learn about the 
% interpretation of the state vector.

% Octave version: ODE syntax is slightly different w.r.t. Matlab.
%  - we can specify a set of discontinuous points in the 
%    derivative (the effect is negligible)
%  - no need to resample

% Integrate
x_0=ChenModelInit();
ChenModelX=@(x,t) ChenModel(t,x);
t_crit=0:6:60;
t=0:60;
x=lsode(ChenModelX,x_0,t,t_crit);

%% Plot of cumulative secretion (quick test)
plot(t,x(:,11));

%% Average secretion, i.e., tau=2 min
% measured=4.5*(SE - delay(SE, tau));
SE_res=x(:,11);
N=length(SE_res);
measured=4.5*(SE_res(3:N)-SE_res(1:(N-2)));

plot(measured,'o-');
xlabel 'Time (min)';
ylabel 'ISR (pg/islet/min)';
grid;


