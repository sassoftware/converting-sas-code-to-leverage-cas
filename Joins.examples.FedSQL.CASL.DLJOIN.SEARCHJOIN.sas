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
   drop team div division league position ;
run;

/* set the active CASLIB */
options caslib=casuser;

/* FedSQL Left join example */
proc FEDSQL sessref=casauto;
     create table fedsql as
     select distinct a.div, a.division, a.league, a.position, a.team, b.*
	  from baseball_location as a left join
	  baseball_stats as b
         on a.name=b.name;
quit;

/* CASL Join Examples */
proc cas;
loadactionset 'searchAnalytics';
loadactionset 'deepLearn';
quit;

/* Deep Learning Action Set dljon action: Examples */
/* joinType="APPEND" | "FULL" | "INNER" | "LEFT" | "RIGHT" */
proc cas;
  deepLearn.dlJoin /       
      joinType="LEFT"                           
      annotatedTable={name="baseball_location"}
      casOut={name="dlJoin", replace=TRUE}
      id="name"
      table={name="baseball_stats"};
   run;
quit;

/* searchAnalytics Action Set searchJoin action: Examples */
/* joinType="APPEND" | "FULL" | "INNER" | "LEFT" | "RIGHT" */
proc cas;
   searchAnalytics.searchJoin /   
      joinType="LEFT"                         
      casOut={name="searchJoin", replace=TRUE}
      leftTable={columns={{isKey=TRUE, name="name"},  
                          {name="name", 
                           reName="name_left"
                           }
                         }
                 table={name="baseball_location"}
                }
      rightTable={columns={{isKey=TRUE, name="name"},  
                           {name="name", 
                            reName="name_right"
                           }
                          }
                  table={name="baseball_stats"}
                 };
run;
quit;

