/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
cas sessopts=(metrics=true);
caslib _all_ assign;

data casuser.baseball;
   set sashelp.baseball;
run;

data casuser.baseball2;
   set casuser.baseball;
   x=nruns/nhits;
run;
