Introduction
============


This folder contains several implementations of [Chen-Wang-Sherman's
model](http://dx.doi.org/10.1529%2Fbiophysj.107.124990) of insulin
secretion based on kinetic modeling of granule exocytosis [1]. The
goal of all implementations is to reproduce the paper's Figures 2 and
4.


Implementation remarks
----------------------

Each of the implementations is a refactoring of the original XPP code
(found in Ref. 2 above). 

Modular language constructs have been used
where possible to split the model into separate calcium and vesicle
components for readability, as follows. 


Component | Description                                          
----------|-----------------------------------------------------
Membrane  | A square voltage source                              
Calcium   | Calcium dynamics, with two state variables (Cmd, Ci) 
Granules  | The kinetic chain of granule compartments            
ISR       | "Instantaneous" (2-min delayed) secretion delta      


Variables, parameters and units have been kept the same as the
original code. Resupply rates $r_1$ and $r_2$ are affected by two
different parameters, called `Kp` and `Kp2` in the code, with the same
value; the equations use a single symbol $K_p$. Intervals given for
variables and parameters reflect the ones used to reproduce paper’s
Figure 4.

The model and data have been derived from publications and
supplementary material (Refs. 1-2).  The conversions rely heavily on
the [original
implementation](http://mrb.niddk.nih.gov/sherman/gallery/beta/Vesicle/henquin-pools.ode)
in XPP-AUT.



Overview of the model
-------------

The model includes: a membrane; two types of inward Ca++ voltage-gated
channels (L- and R-type); two corresponding compartments for calcium
(microdomain and cytosol, respectively, Figure a below);
insulin-carrying vesicles, arranged as a chain of states (from
resupply to releasing, Figure b).

*	Membrane depolarization is modeled as an input function V(t); 
*	V influences the fraction of open L- and R- channels through the sigmoid function minf(V);
*	Ions flow through L-type channels into Cmd and through R-type channels into Ci (Ref. 1, Figure 1 and Figure a, left);
*	Ci leaks through the currents SERCA, PMCA, NCX and leak (eq. (6) and Figure a, right);
*	Ci gates priming (r2) and resupply (r3) rates for pre-docked granules;
*	Cmd gates binding and fusion.

The equations for Cmd, Ci are a nonlinear 2-ODE system coupled to the
membrane depolarization (glucose) input. Granule compartments N<…> are
a linear 10-ODE system with time-varying coefficients. Secretion is a
simple integral; ISR is the secretion in the last 2 min (per min). The
original paper used a least-squares approach to fit the following
parameters: *gL, B, k1, k-1, r1, r-1, r20, r-2, r30, r-3, u1, u2, u3,
Kp,* plus the steady state (used as initial values).


Interface
---------

| Direction | Variable | Description                                                                                                                                                                           |
|-----------+----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Input     | *V(t)*   | membrane depolarization. Square wave between -70 and -20 mV with 6 min down and 6 min up to reproduce Figure 4, left; steady high for Figure 4, right. Other protocols are also used. |
| Output    | *ISR*    | “Instantaneous” insulin secretion in the last 2 min (per minute). The model predicts (and parameters were fitted to reproduce) this quantity.                                         |




Author
------

Conversions by T. Giorgino (ISIB-CNR), heavily borrowing from the XPP-AUT
original. 24-8-2012.





The conversions
============

## Modelica

Modelica is an excellent general-purpose modeling language. The
implementation provided was tested on OpenModelica and Dymola.  Both
code-only (`HenquinPools_r8.mo`) and an OpenModelica notebook are
provided.



## Matlab and Octave

Use either `ChenModel_run_matlab.m` or `ChenModel_run_octave.m`
depending on the software you are using. The other files are common
between the two.

Tested in Matlab R2012a and Octave 3.6.2.


## Simulink

Tested in R2012a. Care has been used to allow for native code
generation.

| File               | Description                                                        |
|--------------------+--------------------------------------------------------------------|
| `chen_init.m`      | Matlab file containing the model's constants. Evaluate this first. |
| `chen_r2.mdl`      | Simulink model                                                     |
| `chen_r2_html.zip` | HTML representation of the model                                   |
| `functions.txt`    | Readable content of the FCN blocks                                 |



## Antimony and SBML

Antimony code and the corresponding SBML translations, produced by
Lucien Smith's [QTAntimony](http://antimony.sourceforge.net/). Tested
with QTAntimony 2.3 beta.


| File                           | Description                              |
|--------------------------------+------------------------------------------|
| `4_henquin-pools-toni_r5.ant`  | Antimony implementation                  |
| `4_henquin-pools-toni_r5.sbml` | Flattened SBML generated by QTAntimony   |
| `NOTES.txt`                    | Implementation and compatibility remarks |

These codes are automatically generated by the Antimony engine:

* Flat SBML. Tested in [COPASI](http://www.copasi.org) 4.8, [RoadRunner/SBW
  Simulation Tool](http://sbw.sourceforge.net) v1.4.4424.32048, and 
  others. See enclosed NOTES.txt file for details.

* Modular SBML, according to the
  [sbml-comp](http://sbml.org/Documents/Specifications/SBML_Level_3/Packages/comp)
  extension.



## Berkeley Madonna

Copy and paste the code provided in `ChenModel.bm.txt` into the
program's Equations panel. Tested with Madonna v. 9.0.74, JEngine 1.8,
JRE 1.6.0 .


## XPP-AUT

Original XPP-AUT implementation straight out from ref. [2], with added
comments.


References
==========

1. Chen Y, Wang S, Sherman A. Identifying the Targets of the
   Amplifying Pathway for Insulin Secretion in Pancreatic β-Cells by
   Kinetic Modeling of Granule Exocytosis. Biophysical Journal. 2008
   Set 1;95(5):2226–41. [doi:10.1529/biophysj.107.124990](http://dx.doi.org/10.1529%2Fbiophysj.107.124990)

2. Supplementary material for the above (online) “Beta Cell Exocytosis
   Model”,
   http://mrb.niddk.nih.gov/sherman/gallery/beta/Vesicle/henquin-pools.ode


