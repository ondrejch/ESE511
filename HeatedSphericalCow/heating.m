clear all;        # clear workspace.
pkg load odepkg;  # load odepkg.

# Octave script to solve
# dT/dt = a P(t) - b T^4
# Ondrej Chvala, for ESE 511, 2020-10-11

global a       = 5;
global b       = 1e-10; 
global Tinit   = 300;
global Psteady = Tinit**4 * b/a;

# Initial y and t values
y0 = Tinit;
t0 = 1900;
global tmax = 2400; # length of time for which to evaluate the equations

function P = power(t)
  global Psteady;
   if (t<2000) 
     P = Psteady;
   else   
     # Select type fo heating
     P = Psteady * ((t-2000)/2000+1);
     #P = Psteady * 1.2;
   endif
endfunction

function tempdot = temperature(t,y,power)
  global a;
  global b;
  tempdot = a * power(t) - b * y**4;
endfunction

vopt = odeset ("RelTol", 1e-5, "AbsTol", 1e-5, "NormControl","on", "InitialStep",2.0, "MaxStep",1.0);%, "OutputFcn", @odeplot);

sol = ode45(@(t,y) temperature(t,y,@power),[t0 tmax],y0,vopt);

tsol = sol.x; ysol = sol.y;

# Plot figure 1, T(t) vs t.
clf('reset');
figure(1);
#F1 = plot(tsol,ysol);
F1 = plotyy(tsol,ysol,tsol,arrayfun (@power, tsol));
X1 = xlabel('time [a.u.]');
%set(X1,'FontName','Times New Roman','fontsize',14);
axis([t0,tmax, Tinit-0.5, ysol(length(ysol))+0.5] );
Y1 = ylabel(F1(1),'Temperature [a.u.K]');
Y2 = ylabel(F1(2),'Heating power [a.u.]');
%set(Y1,'FontName','Times New Roman','fontsize',14);