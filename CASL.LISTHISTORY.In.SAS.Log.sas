/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* the CAS option LISTHISTORY will display in the SAS Log the CASL actions */
cas;
%put  &_sessref_;
caslib _all_ assign;

data casuser.baseball;
   set sashelp.baseball;
run;
options sessopts=(metrics=true);
proc freqtab data=casuser.baseball;
   table div * team  /
      crosslist chisq measures(cl);
run;
cas &_sessref_ listhistory;
