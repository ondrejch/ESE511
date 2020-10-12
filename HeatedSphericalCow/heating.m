% Octave script to solve:  dT/dt = a P(t) - b T^4
% Ondrej Chvala, for ESE 511, 2020-10-11
clear all;        % clear workspace
pkg load odepkg;  % load odepkg

% Type of heating P(t)
% 1 = step change
% 2 = linear heating rammp up
% 3 = linear heating ramp up and steady
% 4 = linear heating ramp up and down
global heating_type = 4;

global a       = 5;              % Arbitrary constants a, b
global b       = 1e-10;          % to make the equations behave
global Tinit   = 300;            % Initial equilibrium temperature
global Psteady = Tinit**4 * b/a; % Heating power corresponding to Tinit

% Initial y=T and t=time values
y0 = Tinit;
t0 = 1900;
global tmax = 2500; % length of time for which to evaluate the equations

% Heating power function
function P = power(t)
  global Psteady;
  global heating_type;
  if (t<2000)
     P = Psteady;
  elseif (t>=2000 && t<2100) 
    switch (heating_type) % Select type of heating at t=2000
     case 1
       P = Psteady * 1.2;                    % step change
     case {2,3,4}
       P = Psteady * ((t-2000)/2000+1);      % linear 
    endswitch
  elseif (t>=2100)
    switch (heating_type)
     case 1
       P = Psteady * 1.2;                    % step change
     case 2
       P = Psteady * ((t-2000)/2000+1);      % linear 
     case 3
       P = Psteady * ((2100-2000)/2000+1)
     case 4
       P = Psteady * ((2100-2000)/2000+1) * ((2100 - t)/2000+1)
       if (P<Psteady)
         P = Psteady
       endif
    endswitch  
  endif
endfunction

% ODE for temperature: dT/dt = a P(t) - b T^4
function tempdot = temperature(t,y,power)
  global a;
  global b;
  tempdot = a * power(t) - b * y**4;
endfunction

% Setup solver
vopt = odeset ("RelTol", 1e-5, "AbsTol", 1e-5, "NormControl","on", "InitialStep",2.0, "MaxStep",1.0);%, "OutputFcn", @odeplot);
% Run solver
sol = ode45(@(t,y) temperature(t,y,@power),[t0 tmax],y0,vopt);
% Extract solution
tsol = sol.x; ysol = sol.y; psol = arrayfun (@power, tsol)

% Plot T(t) and P(t) vs t.
clf('reset');
figure(1);
%F1 = plot(tsol,ysol);
F1 = plotyy(tsol,ysol,tsol,psol);
X1 = xlabel('time [a.u.]');
%set(X1,'FontName','Times New Roman','fontsize',14);
axis([t0,tmax, Tinit-0.1, max(ysol)+0.1])
set(F1(2),"YLim", [min(psol)*0.99, max(psol)*1.01]);
Y1 = ylabel(F1(1),'Temperature [a.u.K]');
Y2 = ylabel(F1(2),'Heating power [a.u.]');
%set(Y1,'FontName','Times New Roman','fontsize',14);
