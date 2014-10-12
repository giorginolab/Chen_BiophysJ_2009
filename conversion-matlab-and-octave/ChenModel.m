% Model of the combined calcium + granule compartments, as per Yi-der Chen,
% Shaokun Wang, and Arthur Sherman, doi:10.1529/biophysj.107.124990

% Identifying the Targets of the Amplifying Pathway for Insulin Secretion
% in Pancreatic β-Cells by Kinetic Modeling of Granule Exocytosis

% Based on the original XPP model,
% http://lbm.niddk.nih.gov/sherman/gallery/beta/Vesicle/

% Toni Giorgino  toni.giorgino@isib.cnr.it

% State space has a dimension of 11. Correspondences shown below
%  Here		XPP	Paper	Note
%  x(1)		Cmd	 	Microdomain [Ca++]
%  x(2)		Ci		Cytosol [Ca++]
% -----------
%  x(3)		N1		Primed (II)
%  x(4)		N2		Bound
%  x(5)		N3		Triggered
%  x(6)		N4		Fused
%  x(7)		N5		Primed (I)
%  x(8)		N6		Just arrived from Reserve Pool
%  x(9)		NF		Fused (II)
%  x(10)	NR		Releasing 
% -----------
%  x(11)	SE		Secretion (integrated)

% Note that equations for Cmd, Ci are a nonlinear 2-ODE system coupled to
% the glucose (voltage) input. Granule compartments are a linear 10-ODE
% system with time-varying coefficients. Secretion is a simple integral.

% Voltage (stepped) input V 
%   --> fraction of opened channels minf(V), eq. (5)
%   --> ion flux through L-type channels IL ~ minf(V)
%   --> ion flux through R-type channels IR ~ .25 * IL
%   --> Ci and Cmd are replenished through these channels
%   --> Ci leaks through three currents (see expression for L)

% Ci  gates priming (r2) and resupply (r3) rates for pre-docked granules
% Cmd gates binding and fusion

% Parameters as given in the paper. 



function dx=ChenModel(t,x)

    % Global parameters
    ts=60; % Minutes
    
    % Trick to multiple-assign state to logical variable names
    tmp=num2cell(x);
    [Cmd Ci N1 N2 N3 N4 N5 N6 NF NR SE]=tmp{:};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calcium dynamics
    [dCmd dCi]=ChenModelCalcium(t,Cmd, Ci);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Granule dynamics
       
    % Potentiation factor
    % % GlucFact = 1.2 for 3 G, 0 for 0 G, and Grest=0 for 0 G too
    GlucFact=0;

    % The inter-compartment kinetic rates
    k1=20; km1=100; r1=0.6; rm1=1; r20=0.006; rm2=0.001;
    r30=1.205; rm3=0.0001; u1=2000; u2=3; u3=0.02;
    Kp=2.3; Kp2=2.3;
    
    % % Vesicles: initial conditions
    %    N1(start=14.71376);
    %    N2(start=0.612519);
    %    N3(start=0.0084499);
    %    N4(start=5.098857e-6);
    %    N5(start=24.539936);
    %    N6(start=218.017777);
    %    NF(start=0.003399);
    %    NR(start=0.50988575);
    %    SE(start=0.0);

    % EQUATIONS

    % Rates for pre-docking granules depend on cytosol Ca++ (Ci)
    r2 = r20*Ci/(Ci + Kp2);
    r3 = GlucFact*r30*Ci/(Ci + Kp);

    % Rates for docked granules depend on microdomain Ca++ (Cmd)  
    dN1 = ts*(-(3*k1*Cmd + rm1)*N1 + km1*N2 + r1*N5); % Primed
    dN2 = ts*(3*k1*Cmd*N1 -(2*k1*Cmd + km1)*N2 + 2*km1*N3); % Bound
    dN3 = ts*(2*k1*Cmd*N2 -(2*km1 + k1*Cmd)*N3 + 3*km1*N4); % Triggered
    dN4 = ts*(k1*Cmd*N3 - (3*km1 + u1)*N4); % Fused
    dN5 = ts*(rm1*N1 - (r1 + rm2)*N5 + r2*N6); %Primed
    dN6 = ts*(r3 + rm2*N5 - (rm3 + r2)*N6); % Docked
    dNF = ts*(u1*N4 - u2*NF); % Fused
    dNR = ts*(u2*NF - u3*NR); % Releasing
    dSE = ts*(u3*NR); % Secretion

    % Compose the state vector
    dx=[dCmd dCi dN1 dN2 dN3 dN4 dN5 dN6 dNF dNR dSE]';

end


