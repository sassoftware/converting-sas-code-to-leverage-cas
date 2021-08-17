/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
cas;
/* CAS enabled */
/* Loading user define action set tableSizeHuman */
/* You must modify the path in the CASLIB USDA */
PROC CAS;
   table.addCaslib /
   caslib='UDAS'
   dataSource={srctype='path'}
   path="/viyafiles/sasss1/userDefinedActionSets";
run;
quit;

caslib _all_ assign; 

proc cas;
 builtins.actionSetFromTable /
 table="tableSizeHuman.sashdat"
 name="tableSizeHuman";
 quit;

data casuser.baseball(compress=yes);
   set sashelp.baseball;
run;

proc cas;
   tableSizeHuman.tableStats / caslib="casuser" table="baseball";
run;
