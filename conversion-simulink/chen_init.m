%% Parameters and initial conditions for calcium part
    pc.ts=60;
    pc.Jsercamax=41.0;
    pc.Kserca=0.27;
    pc.Jpmcamax=21.0;
    pc.Kpmca=0.5;
    pc.Jncx0=18.67;
    pc.Jleak=-0.94;


    pc.gL=250;
    pc.Vm=-20;
    pc.sm=5;
    pc.Vca=25;

    pc.alpha=5.18e-15;
    pc.vcell=1.15e-12;
    pc.vmd=4.2e-15;
    pc.fv=pc.vmd/pc.vcell;


    pc.fi=0.01;
    pc.fmd=0.01;
    pc.B=200;

    pc.Cmd0=0.0674;
    pc.Ci0=0.06274;
    
    % For some stupid reason 2009b doesn't like "pc"
    p_c=pc;

    % May be required for proper structure parameters
    % See page 4-50 of Simulink Coder 2012a
    pc_p=Simulink.Parameter;
    pc_p.Value=pc;
    pc_p.CoderInfo.StorageClass='SimulinkGlobal';

      
      %%

    % GlucFact = 1.2 for 3 G, 0 for 0 G, and Grest=0 for 0 G too
    pg.GlucFact=0;
    pg.ts=60;

    % The inter-compartment kinetic rates
    pg.k1=20;
    pg.km1=100;
    pg.r1=0.6;
    pg.rm1=1;
    pg.r20=0.006; 
    pg.rm2=0.001;
    pg.r30=1.205; 
    pg.rm3=0.0001; 
    pg.u1=2000; 
    pg.u2=3; 
    pg.u3=0.02;

    pg.Kp=2.3; 
    pg.Kp2=2.3;

    %  Initial states
    pg.N1_0=14.71376;
    pg.N2_0=0.612519;
    pg.N3_0=0.0084499;
    pg.N4_0=5.098857e-6;
    pg.N5_0=24.539936;
    pg.N6_0=218.017777;
    pg.NF_0=0.003399;
    pg.NR_0=0.50988575;
    pg.SE_0=0.0;

    pg.N_0=[pg.N1_0 pg.N2_0 pg.N3_0 pg.N4_0 pg.N5_0 pg.N6_0 ...
            pg.NF_0 pg.NR_0  pg.SE_0]';
        
    pg_p=Simulink.Parameter;
    pg_p.Value=pg;
    pg_p.CoderInfo.StorageClass='SimulinkGlobal';

%%

tic; for i=1:10;yy=sim('chen_r2');end;toc;
