/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* CASL GROUPBY Action Example */ 

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;

/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;

%put  &_sessref_;

caslib  _all_ assign;

data casuser.baseball;
   set sashelp.baseball;
run;

proc delete data=casuser.baseball_groupby;
run;

options caslib="casuser";
proc fedsql  sessref=casauto;
   create table baseball_groupby 
   as
   (select  sum(nhits) as nhits_sum
   from baseball
   group by div, team) ;
quit;

proc cas;
   session casauto;
   simple.groupBy result=r status=s /   
      inputs={"DIV" "TEAM"},
      weight="nhits",            
      aggregator="SUM",  
      table={name="baseball"},              
      casout={name="casl_baseball_groupby",   
         replace=true};
run;
