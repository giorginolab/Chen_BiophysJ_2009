% Derivatives of the [Ca++] in microdomain and cytosol. Calls the
% SquareSource function to get the membrane potential (V) at time t.

function [dCmd dCi]=ChenModelCalcium(t,Cmd,Ci)

    % Global parameters   
    ts=60; % Conversion to minutes

    % These names mirror the original XPP model 
    fmd=0.01; fi=0.01; B=200; fv=0.00365; 
    alpha=5.18e-15; vmd=4.2e-15; vcell=1.15e-12;
    gL=250; Vm=-20; Vca=25; sm=5;

    %  % Leak fluxes
    Jsercamax=41.0; Kserca=0.27; Jpmcamax=21.0;
    Kpmca=0.5; Jleak=-0.94; Jncx0=18.67;

    %  % Ca++ concentrations, with initial values
    %    Cmd(start=0.0674);
    %    Ci(start=0.06274);

    % EQUATIONS    

    % Forced membrane potential
    V=ChenModelMembrane(t);

    %  % The leak currents follow these three kinetic laws
    Jserca = Jsercamax*Ci^2/(Kserca^2 + Ci^2);
    Jpmca = Jpmcamax*Ci/(Kpmca + Ci);
    Jncx = Jncx0*(Ci - 0.25);
    L=Jserca + Jpmca + Jncx + Jleak;

    %  % % Rates are in seconds, following Yi-der, multiply ODE RHS's by ts to get in minutes

    %  % Currents passing through the voltage-switched channels
    IL=gL*minf(V)*(V- Vca);
    IR=0.25*IL;
  
    %  % % Molar fluxes:
    JL = alpha*IL/vmd;
    JR = alpha*IR/vcell;

    %  % Compartment model
    dCmd = ts*(-fmd*JL - fmd*B*(Cmd - Ci));
    dCi  = ts*(-fi*JR + fv*fi*B*(Cmd - Ci) - fi*L);
    
end




%% Auxiliary functions --------------------------------------

% The voltage-gated switching function. It is a function of V, which 
% returns the fraction of open channels. Parameters from paper. 
% To test-
%  v=linspace(-100,20,100);
%  plot(v,minf(v))

function o=minf(V)
	Vm=-20;
	Sm=5;
	o = 1./(1 + exp((Vm-V)./Sm));
end



