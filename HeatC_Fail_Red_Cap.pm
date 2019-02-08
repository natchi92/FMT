ctmc

const int YEAR = 364;

//--------------------------------------------------------
// Constants for EBEs
//
const int DEG_N1 = 5;
const int DEG_N2 = 4;
const int DEG_N3 = 5;
const int DEG_N4 = 7;
const int DEG_N5 = 5;
const int DEG_N6 = 3;
const int DEG_N7 = 3;
const int DEG_N8 = 5;
const double DEG_MTTF1 = 20.0*YEAR;
const double DEG_MTTF2 = 35.0*YEAR;
const double DEG_MTTF3 = 31.0*YEAR;
const double DEG_MTTF4 = 17.0*YEAR;
const double DEG_MTTF5 = 25.0*YEAR;
const double DEG_MTTF6 = 10.0*YEAR;
const double DEG_MTTF7 = 10.0*YEAR;
const double DEG_MTTF8 = 20.0*YEAR;

//--------------------------------------------------------
// Constants for maintenance DELAY modules (Repair, Inspection, Clean, etc.)
//
const int N = 4;
const int N_INSP = N;
const int N_REP  = N;
const int N_OH   = N;
const int N_CLN  = N;
const int N_RPLC = N;
const double MT_INSP =  0.5*YEAR;  // an inspection  is scheduled every ... days
const double MT_REP  =  2.0*YEAR;  // a repair check is scheduled every ... days
const double MT_OH   = 15.0*YEAR;  // an overhaul    is scheduled every ... days
const double MT_CLN  = 1.0;        // a clean   takes ... days
const double MT_RPLC = 7.0;        // a replace takes ... days

//--------------------------------------------------------
// Constants for costs
//
const int COST_INSP = 5;
const int COST_REP  = 0;  // costs are in the triggered clean, if any
const int COST_OH   = 0;  // costs are in the triggered replace
const int COST_CLN  = 100;
const int COST_RPLC = 5000;
const int COST_OP   = 1;          // costs per day of (proper) system operation
const int COST_NOOP = 4*COST_OP;  // costs per day of ***no*** system operation

//--------------------------------------------------------
// Synchronised start of all modules
//
module Kickstart
	start : bool init true;
	[trigger] start -> (start'=false);
endmodule

//--------------------------------------------------------
// Extended Basic Events
//
module EBE1
	s1 : [0..DEG_N1];
	// Kickstart
	[trigger] s1 = 0 -> (s1'=1);
	// Degradation
	[  ] 0 < s1 & s1 < DEG_N1-1 -> (DEG_N1-1.0)/DEG_MTTF1 : (s1'=s1+1);
	[f1]          s1 = DEG_N1-1 -> (DEG_N1-1.0)/DEG_MTTF1 : (s1'=s1+1);
	// Maintenance: clean
	[cln] s1 > 1 -> (s1'=s1-1);
	[cln] s1 = 1 -> true;
	// Maintenance: replace
	[rplc] true -> (s1'=1);
endmodule
//
//	module EBE2 = EBE1 [
//		s1        = s2,
//		f1        = f2,
//		DEG_N1    = DEG_N2,
//		DEG_MTTF1 = DEG_MTTF2
//	] endmodule
//	//
//	module EBE3 = EBE1 [
//		s1        = s3,
//		f1        = f3,
//		DEG_N1    = DEG_N3,
//		DEG_MTTF1 = DEG_MTTF3
//	] endmodule
//	//
//	module EBE4 = EBE1 [
//		s1        = s4,
//		f1        = f4,
//		DEG_N1    = DEG_N4,
//		DEG_MTTF1 = DEG_MTTF4
//	] endmodule
//
module EBE5 = EBE1 [
	s1        = s5,
	f1        = f5,
	DEG_N1    = DEG_N5,
	DEG_MTTF1 = DEG_MTTF5
] endmodule
//
module EBE6 = EBE1 [
	s1        = s6,
	f1        = f6,
	DEG_N1    = DEG_N6,
	DEG_MTTF1 = DEG_MTTF6
] endmodule
//
module EBE7 = EBE1 [
	s1        = s7,
	f1        = f7,
	DEG_N1    = DEG_N7,
	DEG_MTTF1 = DEG_MTTF7
] endmodule
//
module EBE8 = EBE1 [
	s1        = s8,
	f1        = f8,
	DEG_N1    = DEG_N8,
	DEG_MTTF1 = DEG_MTTF8
] endmodule

//--------------------------------------------------------
// Useful formulae
//
formula thresh1 = 1<s1 & s1<DEG_N1;
//	formula thresh2 = 1<s2 & s2<DEG_N2;
//	formula thresh3 = 1<s3 & s3<DEG_N3;
//	formula thresh4 = 1<s4 & s4<DEG_N4;
formula thresh5 = 1<s5 & s5<DEG_N5;
formula thresh6 = 1<s6 & s6<DEG_N6;
formula thresh7 = 1<s7 & s7<DEG_N7;
formula thresh8 = 1<s8 & s8<DEG_N8;
formula threshold =
	thresh1 |
//	thresh2 |
//	thresh3 |
//	thresh4 |
	thresh5 |
	thresh6 |
	thresh7 |
	thresh8 ;
//
formula trig1 = 1<s1;
//	formula trig2 = 1<s2;
//	formula trig3 = 1<s3;
//	formula trig4 = 1<s4;
formula trig5 = 1<s5;
formula trig6 = 1<s6;
formula trig7 = 1<s7;
formula trig8 = 1<s8;
formula trigger =
	trig1 |
//	trig2 |
//	trig3 |
//	trig4 |
	trig5 |
	trig6 |
	trig7 |
	trig8 ;

//--------------------------------------------------------
// Periodic check (e.g. inspections, repair checks, etc.)
//
const int NN = 2;    // dummy value for DELAY template
const int MT = 99;   // dummy value for DELAY template
//
module DELAY
	phase : [0..NN] init 0;
	// Kickstart
	[trigger] phase = 0 -> (phase'=1);
	// Cyclic evolution
	[] 0 < phase & phase < NN -> (NN-1.0)/MT : (phase'=phase+1);
	[check]        phase = NN -> (NN-1.0)/MT : (phase'=1);
endmodule
//
module Inspection = DELAY
[
	check = check_insp,
	phase = phase_insp,
	NN    = N_INSP,
	MT    = MT_INSP
]
endmodule
//
module Repair = DELAY
[
	check = check_rep,
	phase = phase_rep,
	NN    = N_REP,
	MT    = MT_REP
]
endmodule
//
module Overhaul = DELAY
[
	check = force_oh,
	phase = phase_oh,
	NN    = N_OH,
	MT    = MT_OH
]
endmodule

//--------------------------------------------------------
// Repair module: Listens to periodic checks and starts maintenance if necessary
//
const int N_RM = N_CLN;
module RM
	rm    : [0..N_RM] init 0;
	in_oh : bool init false;
	// Periodic inspection takes place
	[check_insp] rm = 0 & !threshold -> true;     // no EBE in "thresh" state
	[check_insp] rm = 0 &  threshold -> (rm'=1);  // clean started
	// Periodic repair check takes place
	[check_rep]  rm = 0 & !trigger   -> true;     // no EBE is degraded
	[check_rep]  rm = 0 &  trigger   -> (rm'=1);  // clean started
	// Periodic overhaul takes place (overrides any other maintenance)
	[force_oh] true -> (in_oh'=true) & (rm'=1);   // full system replacement started
	// Cleaning
	[   ]  !in_oh & 0 < rm & rm < N_CLN  -> (N_CLN-1.0) / MT_CLN : (rm'=rm+1);
	[cln]  !in_oh &          rm = N_CLN  -> (N_CLN-1.0) / MT_CLN : (rm'=0);  // clean completed
	// Replacing
	[    ]  in_oh & 0 < rm & rm < N_RPLC -> (N_RPLC-1.0)/MT_RPLC : (rm'=rm+1);
	[rplc]  in_oh &          rm = N_RPLC -> (N_RPLC-1.0)/MT_RPLC : (rm'=0) & (in_oh'=false);  // replacement completed
endmodule

//--------------------------------------------------------
// KPIs: Formulae & Rewards
//
formula Failure =
	(s1=DEG_N1) |
//	(s2=DEG_N2) |
//	(s3=DEG_N3) |
//	(s4=DEG_N4) |
	(s5=DEG_N5) |
	(s6=DEG_N6) |
	(s7=DEG_N7) |
	(s8=DEG_N8) ;
label "failure" = (Failure);
//
rewards "Availability"
	!Failure : 1;
endrewards
//
rewards "ENF_EBEs"
	[f1] true : 1;
//	[f2] true : 1;
//	[f3] true : 1;
//	[f4] true : 1;
	[f5] true : 1;
	[f6] true : 1;
	[f7] true : 1;
	[f8] true : 1;
endrewards
//
rewards "ENF_TLE"
	[f1] !Failure : 1;
//	[f2] !Failure : 1;
//	[f3] !Failure : 1;
//	[f4] !Failure : 1;
	[f5] !Failure : 1;
	[f6] !Failure : 1;
	[f7] !Failure : 1;
	[f8] !Failure : 1;
endrewards
//
rewards "cost_op"  // FIXME: Is this OK Nathalie?
	!Failure : COST_OP;
	 Failure : COST_NOOP;
endrewards
//
rewards "cost_insp"
	[check_insp] true : COST_INSP;
endrewards
//
rewards "cost_cln"
	[cln] true : COST_CLN;
endrewards
//
rewards "num_insp"
	[check_insp] true : 1;
endrewards
//
rewards "num_rep"
	[check_rep] true : 1;
endrewards
//
rewards "num_cln"
	[cln] true : 1;
endrewards
