#!/bin/bash

# Notes for the conversion of Chen-Sherman's model in PharmML


# The human-readable pieces are translated to PharmML via the
# http://infix2pharmml.sourceforge.net service.  Based directly off
# the original XPP version.

c="perl ./convert.pl -q"


# Heaviside function
rm functions.xml
$c "heavx(x):= (abs(x)+x)/(2*abs(x)+1e-5)" >> functions.xml


# Modulus function

#PharmML has the `rem()` function. In case it does not accept
#real-valued arguments, the following can be used.

$c "modulus(a,b):=a-b*floor(a/b)" >> functions.xml



# Saturation function
$c "minf(v):= 1/(1 + exp((Vm-V)/sm))" >> functions.xml



# Parameters
# TBD


# Voltage source - a square source
# Microdomain and cytosol Ca++ concentrations
# Chain of granules

$c -q -s "
IL:=gL*minf(v=V)*(V- Vca)
IR:=0.25*IL

JL:=alpha*IL/vmd
JR:=alpha*IR/vcell

Jserca := Jsercamax*Ci^2/(Kserca^2 + Ci^2)
Jpmca := Jpmcamax*Ci/(Kpmca + Ci)
Jncx := Jncx0*(Ci - 0.25)
L:=Jserca + Jpmca + Jncx + Jleak

V:=Vrest + (Vburst - Vrest)*(heav(x=rem(t, tcycle)) - heav(x=rem(t,tcycle) - toff))

diff(Cmd,t):= ts*(-fmd*JL - fmd*B*(Cmd - Ci))
diff(Ci,t):= ts*(-fi*JR + fv*fi*B*(Cmd - Ci) - fi*L)

r2:=r20*Ci/(Ci + Kp2)
r3:=GlucFact*r30*Ci/(Ci + Kp)

diff(N1,t):= ts*(-(3*k1*Cmd + rm1)*N1 + km1*N2 + r1*N5)
diff(N2,t):= ts*(3*k1*Cmd*N1 -(2*k1*Cmd + km1)*N2 + 2*km1*N3)
diff(N3,t):= ts*(2*k1*Cmd*N2 -(2*km1 + k1*Cmd)*N3 + 3*km1*N4)
diff(N4,t):= ts*(k1*Cmd*N3 - (3*km1 + u1)*N4)
diff(N5,t):= ts*(rm1*N1 - (r1 + rm2)*N5 + r2*N6)
diff(N6,t):= ts*(r3 + rm2*N5 - (rm3 + r2)*N6)
diff(NF,t):= ts*(u1*N4 - u2*NF)
diff(NR,t):= ts*(u2*NF - u3*NR)

diff(SE,t):= ts*(u3*NR)

docked := N6 + N5 + N1
primed := N5 + N1
" > structural.xml

# PharmML lacks the delay() function
# measured:=4.5*(SE - delay(SE, tau))



# Merge the two
sed '/<!-- Insert FunctionDefinition here -->/ r functions.xml' structural.xml > model.xml


# Final pp
xml_pp -i model.xml

