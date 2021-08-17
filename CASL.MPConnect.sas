/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* Establish two SAS/CONNECT Sessions */
signon session1 sascmd="!sascmd -nosyntaxcheck -noterminal";
signon session2 sascmd="!sascmd -nosyntaxcheck -noterminal";

/* Submit session 1's code and continue without waiting for session 1 to finish */ 
rsubmit session1 wait=no;
options casdatalimit=10G;
options compress=yes;

cas host="19w47mpp-2.gtp-americas.sashq-d.openstack.sas.com"
    port=5570
    sessopts=(TIMEOUT=99,DQLOCALE=ENUSA);

caslib _all_ assign;

data casuser.cars;
   set sashelp.cars;
run;

proc cas;
session casauto;
simple.regression result=reg status=rc /
      alpha=0.05,
      order=3,
      target="mpg_highway",
      inputs={"weight"},
      table={caslib="casuser", name="cars"};
run;
   if (rc.severity == 0) then do;
      saveresult reg casout="reg1";

      table.fetch /
        fetchvars={
         {name="response", label="Response"},
         {name="regressor", label="Regressor"},
         "intercept", "linear", "quadratic",
         "ymean", "Ystd", "xmean" , "Xstd"},
        table="reg1",
        index=false;
    end;
run; 
quit;
endrsubmit;

/* Submit session 2's code and continue without waiting for session 2 to finish */ 
rsubmit session2 wait=no;
options casdatalimit=10G;
options compress=yes;

cas host="19w47mpp-2.gtp-americas.sashq-d.openstack.sas.com"
    port=5570
    sessopts=(TIMEOUT=99,DQLOCALE=ENUSA);

caslib _all_ assign;

data casuser.cars;
   set sashelp.cars;
run;

proc cas;
session casauto; 
simple.regression result=reg2 status=rc /
      alpha=0.15,
      order=2,
      target="mpg_highway",
      inputs={"weight"},
      table={caslib="casuser", name="cars"};
run;
   if (rc.severity == 0) then do;
      saveresult reg2 casout="reg2";

      table.fetch /
        fetchvars={
         {name="response", label="Response"},
         {name="regressor", label="Regressor"},
         "intercept", "linear", "quadratic",
         "ymean", "Ystd", "xmean" , "Xstd"},
        table="reg2",
        index=false;
    end;

run;
quit;

endrsubmit;

/* Wait for session1 and session2 to finish */
waitfor _all_ session1 session2;

/* Obtain SAS Log and Results from session 1 */
rget session1;

/* Obtain SAS Log and Results from session 2 */
rget session2;

/* Terminate session 1 and session 2 */
signoff session1;
signoff session2;

