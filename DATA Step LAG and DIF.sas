/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* Compute Server Enabled*/
/* LAG and DIF techniques are primarly used with time series data */
option user=work;
data baseball;
   set sashelp.baseball;
   rename nhits= ammount;
run;

data baseball2;
   set baseball;
   lagvar=lag(ammount);
   difvar=dif12(ammount);
run;

proc print data=baseball2;
   var ammount lagvar difvar;
run;
