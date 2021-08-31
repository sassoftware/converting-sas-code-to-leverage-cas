/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* Required Step */
/* SPRE Enabled */
/* Sets the SAS macro variable &DATAPATH */
/* Copy data used in the CAS coding examples to the path defined by the macro variable &DATAPATH */
/* Macro &DATAPATH is used in the CAS coding examples */

/* Set DATAPATH to a path known to your SAS Viya environment */
/* For parallel loading via a CASLIB ensure the paths is known to all CAS worker nodes as well as the CAS controler node */
/* Due to the data sizes used in all examples parallel loading is not a requirement */
%let datapath = /viyafiles/sasss1/data;
%put &datapath;
libname sas7bdat "&datapath";
proc copy in=sashelp out=sas7bdat;
   select baseball cars;
run;

proc contents data=sas7bdat.baseball;
run;

proc contents data=sas7bdat.cars;
run;
