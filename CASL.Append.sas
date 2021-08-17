/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* cas casauto terminate; */
cas;
caslib _all_ assign;

data casuser.baseball_location;
   set sashelp.baseball;
   keep name team div division league position;
run;

data casuser.baseball_stats;
   set sashelp.baseball;
   drop  div division league position ;
run;

/* set the active CASLIB */
options caslib=casuser;

/* CASL Join Examples */
proc cas;
loadactionset 'searchAnalytics';
loadactionset 'deepLearn';
quit;

/* Deep Learning Action Set dljon action: Examples */
/* joinType="APPEND" | "FULL" | "INNER" | "LEFT" | "RIGHT" */
proc cas;
  deepLearn.dlJoin /       
      joinType="APPEND"                           
      annotatedTable={name="baseball_location"}
      casOut={name="dlJoin", replace=TRUE}
      table={name="baseball_stats"};
   run;
quit;

/* searchAnalytics Action Set searchJoin action: Examples */
/* joinType="APPEND" | "FULL" | "INNER" | "LEFT" | "RIGHT" */
proc cas;
   searchAnalytics.searchJoin /   
      joinType="APPEND"                         
      casOut={name="searchJoin", replace=TRUE}
      leftTable={
                 table={name="baseball_location"}
                }
      rightTable={
                  table={name="baseball_stats"}
                 };
run;
quit;

