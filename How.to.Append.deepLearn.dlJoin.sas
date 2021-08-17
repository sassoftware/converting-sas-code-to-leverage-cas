/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* How to append two CAS tables */

cas;
caslib _all_ assign;
%put  &_sessref_;
data CASUSER.CARS CASUSER.CARS2;
   set sashelp.cars;
run;
proc cas;
deepLearn.dlJoin /
  annotatedTable = {name = "CARS2", caslib="CASUSER"}
  table = {name = "CARS2", caslib="CASUSER"}
  id = "_id_" 
  joinType = "APPEND"
  casout = {name = "CARS", caslib="CASUSER", replace=TRUE}
  ;
  print "Appending CASUSER.CARS2 to CASUSER.CARS";
run;
quit;
