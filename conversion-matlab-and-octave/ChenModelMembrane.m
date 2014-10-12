% Model of a square-wave source. This is used to represent the (forced) external membrane potential. 
% To test-
%  test_t=linspace(0,60,600);
%  plot(test_t,SquareSource(test_t))

function V=ChenModelMembrane(t)
	Vrest=-70; Vburst=-20;
	tstep=0.0; ton=6.0; toff=6.0;

        % Uncomment below for Figure 2
        % ton=8/60; toff=8/60;

	% set toff  > 100 for steady stimulus
 	tcycle=ton+toff;
  	V = Vrest + (Vburst - Vrest)*(heav(mod(t, tcycle)) - heav(mod(t,tcycle) - toff));
end


% Heaviside function
function y=heav(x)
	y=.5*(1+sign(x));
end

