/* Yi-der Chen, Shaokun Wang, and Arthur Sherman, Identifying the
   Targets of the Amplifying Pathway for Insulin Secretion in
   Pancreatic β-Cells by Kinetic Modeling of Granule
   Exocytosis. doi:10.1529/biophysj.107.124990

Test conversion of the original model into Modelica: toni.giorgino@isib.cnr.it

This is a conversion from the original model in XPP (ode) format. To
execute the model, load it with loadFile, then issue the following
comman to perform the simulation:
>>  simulate(ISRMeasurement, startTime=0, stopTime=60,numberOfIntervals=500);

This reproduces Figure 4 G0. To make G3, set GlucFact=1.2 .
>>  plot({Cell.N1,measured})

 
To reproduce the other figures, the following changes have to be performed:
 * final time of integration
 * implement a RampedSource ramped potential and use it also for GlucFact
 * change r parameters

It should be possible to perform all of the experiments changing only the ISRMeasurement model "container" code.

Use this syntax to inspect the value of a variable at a given time
>>  val(measured,2.5)
 

The model assumes the following units.
  time: sec
  volume: l
  conductance: pS
  V: mV
  I: fA
  J: uM/s
  alpha: umol/sec/fA

*/


/* 
 * The following block defines the Heaviside auxiliary function (used
 * for square-pulse generation).
 */

function heav "Heaviside function"
  input Real x;
  output Real y;
algorithm
  y := 0.5 * (1+sign(x));
end heav;


/*
 * The voltage-gated switching function.  It is a function of V, which
 * returns the fraction of open channels.
 */

// minf(v) = 1/(1 + exp((Vm-V)/sm))
function minf "Voltage-gate switching function"
  input Real V;
  input Real Vm:=-20, Sm:=5;
  output Real o;
algorithm
  o := 1/(1 + exp((Vm-V)/Sm)); 
end minf;



/*
 * Model of a square-wave source. This is used to represent the
 * (forced) external membrane potential. Parameters (voltages, period
 * and duty-cycle) can be changed when the block is instantiated.
 */

// Square output: Vburst mV for ton ms, then Vrest mV for toff ms, then repeat
model SquareSource "Forcing function for the membrane potential"
  Real V,t;
  parameter Real Vrest=-70, Vburst=-20;
  parameter Real tstep=0.0, ton=6.0, toff=6.0;
  // # set toff  > 100 for steady stimulus
  parameter Real tcycle=ton+toff;
equation
  t = time;
  V = Vrest + (Vburst - Vrest)*(heav(mod(t, tcycle)) - heav(mod(t,tcycle) - toff));
end SquareSource;



/* 
 * This model contains the two calcium compartments. It uses a
 * membrane potential (modeled by the SquareSource defined above). The
 * useful outputs are Ci and Cmd, i.e. the concentrations of Calcium
 * in the cytosol and microdomains respectively.
 */

model CalciumCompartments "Calcium microdomain compartment"

  parameter Real ts=60; // Conversion to minutes

  // Parameter names mirror the original model 
  parameter Real fmd=0.01, fi=0.01, B=200, fv=0.00365; 
  parameter Real alpha=5.18e-15, vmd=4.2e-15, vcell=1.15e-12;
  parameter Real gL=250, Vm=-20, Vca=25, sm=5;

  Real V; // The current voltage (as generated by SquareSource)
  Real IL, IR; // Currents
  Real JL, JR; // Ion fluxes

  // Leak fluxes
  parameter Real Jsercamax=41.0, Kserca=0.27, Jpmcamax=21.0, Kpmca=0.5, Jleak=-0.94, Jncx0=18.67;
  Real L, Jserca, Jpmca, Jncx;

  // Ca++ concentrations, with initial values
  Real Cmd(start=0.0674);
  Real Ci(start=0.06274);
    
equation
   
  // The leak currents follow different kinetic laws
  Jserca = Jsercamax*Ci^2/(Kserca^2 + Ci^2);
  Jpmca = Jpmcamax*Ci/(Kpmca + Ci);
  Jncx = Jncx0*(Ci - 0.25);
  L=Jserca + Jpmca + Jncx + Jleak;

  // # Rates are in seconds, following Yi-der,  I multiply ODE RHS's by ts to get in minutes
  // Currents passing through the voltage-switched channels
  IL=gL*minf(V)*(V- Vca);
  IR=0.25*IL;
  
  // # Molar fluxes:
  JL = alpha*IL/vmd;
  JR = alpha*IR/vcell;

  // Compartment model
  der(Cmd) = ts*(-fmd*JL - fmd*B*(Cmd - Ci));
  der(Ci)  = ts*(-fi*JR + fv*fi*B*(Cmd - Ci) - fi*L);

end CalciumCompartments;

	   
/*
 * Model of the β-cell. It contains the calcium compartments (an
 * instance of CalciumCompartments) and the vesicles (defined here).
 */

model BetaCell "Calcium-vesicle combined model, Chen et al."
  parameter Real ts=60; // Minutes

  // # GlucFact = 1.2 for 3 G, 0 for 0 G, and Grest=0 for 0 G too
  Real GlucFact=1.2;

  // These come out from CA. Defined as local veriables for brevity.
  Real Ci, Cmd;  
  Real r2, r3;  

  // # Vesicles: initial conditions
  Real N1(start=14.71376);
  Real N2(start=0.612519);
  Real N3(start=0.0084499);
  Real N4(start=5.098857e-6);
  Real N5(start=24.539936);
  Real N6(start=218.017777);
  Real NF(start=0.003399);
  Real NR(start=0.50988575);
  Real SE(start=0.0);

  // The inter-compartment kinetic rates
  parameter Real k1=20, km1=100, r1=0.6, rm1=1, r20=0.006, rm2=0.001;
  parameter Real r30=1.205, rm3=0.0001, u1=2000, u2=3, u3=0.02;
  parameter Real Kp=2.3, Kp2=2.3;
  
equation
  // Rates depending on cytosol calcium
  r2 = r20*Ci/(Ci + Kp2);
  r3 = GlucFact*r30*Ci/(Ci + Kp);
  
  // Rates depending on microdomain calcium, and secretion; (8)
  der(N1) = ts*(-(3*k1*Cmd + rm1)*N1 + km1*N2 + r1*N5); // Primed
  der(N2) = ts*(3*k1*Cmd*N1 -(2*k1*Cmd + km1)*N2 + 2*km1*N3); // Bound
  der(N3) = ts*(2*k1*Cmd*N2 -(2*km1 + k1*Cmd)*N3 + 3*km1*N4); // Triggered
  der(N4) = ts*(k1*Cmd*N3 - (3*km1 + u1)*N4); // Fused
  der(N5) = ts*(rm1*N1 - (r1 + rm2)*N5 + r2*N6); //Primed
  der(N6) = ts*(r3 + rm2*N5 - (rm3 + r2)*N6); // Docked
  der(NF) = ts*(u1*N4 - u2*NF); // Fused
  der(NR) = ts*(u2*NF - u3*NR); // Releasing
  der(SE) = ts*(u3*NR); // Secretion

end BetaCell;



/* 
 *  The final model instantiates a BetaCell and performs the time-averaged
 *  ISR measurement.
 */ 

model ISRMeasurement
  SquareSource membranePotential(ton=6,toff=6);
  CalciumCompartments CA;
  BetaCell Cell(GlucFact=0);
  Real SE;                  // Shorthand of SE compartment in BetaCell
  parameter Real tau=2.0;   // # samples collected every 2 minutes
  output Real measured;
equation
  CA.V=membranePotential.V;
  Cell.Ci=CA.Ci;
  Cell.Cmd=CA.Cmd;
  SE=Cell.SE;
  measured=4.5*(SE - delay(SE, tau));
end ISRMeasurement;






