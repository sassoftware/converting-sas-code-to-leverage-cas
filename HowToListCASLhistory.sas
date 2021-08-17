/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* cas casauto terminate; */
cas;
caslib _all_ assign;
data casuser.baseball_stats;
   set sashelp.baseball;
run;
proc means data=casuser.baseball_stats;
run;
cas casauto listhistory _all_; 
