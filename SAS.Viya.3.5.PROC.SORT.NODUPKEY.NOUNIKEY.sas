/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* Requires SAS Viya 3.5+ */
/* CAS Enabled */
/* PROC SORT NODUPKEY and NOUNIKEY on CAS Table Examples */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

data casuser.cars;
   set sashelp.cars;
run;

proc sort data=casuser.cars out=casuser.cars_nodupkey1 nodupkey;
   by origin;
run;
cas &_sessref_ listhistory;

proc sort data=casuser.cars out=casuser.cars_nounikey1 nounikey;
   by origin;
run;
cas &_sessref_ listhistory;

proc sort data=casuser.cars out=casuser.cars_nodupkey2 nodupkey
          dupout=casuser.cars_nodupkey_dupout2;
   by origin;
run;
cas &_sessref_ listhistory;

proc sort data=casuser.cars out=casuser.cars_nounikey3 nounikey
          uniout=casuser.cars_nounikey_uniout3;
   by origin;
run;
cas &_sessref_ listhistory;
