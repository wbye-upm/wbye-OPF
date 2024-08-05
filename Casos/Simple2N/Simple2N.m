function mpc = Simple2N
mpc.version = '2';
mpc.baseMVA = 100.0;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	 3	 0.0	 0.0	 0.0	 0.0	 1	    1.00000	    0.00000	 132.0	 1	    1.05	    0.95;
	2	 1	 250.0	 50.0	 0.0	 0.0	 1	    1.00000	    0.00000	 132.0	 1	    1.05	    0.95;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin
mpc.gen = [
	1	 100.0	 -2.0	 100.0	 -100.0	 1.0	 100.0	 1	 500	 0.0
];

%% generator cost data
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	 0.0	 0.0	 3	   0.000000	  10	   0.000000
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	 2	 0.01	 0.06	 0	 1000	 1000	 1000	 0.0	 0.0	 1	 -30.0	 30.0;

];