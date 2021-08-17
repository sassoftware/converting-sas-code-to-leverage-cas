/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* CAS table info at the CAS worker node level */ 

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;

/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;

%put  &_sessref_;

caslib  _all_ assign;

proc cas; 
 tabledetails /
    caslib="public"
    name="jccardtrain" ; 
  run;
   action table.tabledetails / level='NODE'  name="jccardtrain" caslib="public" ;  
  run ; 
quit;
