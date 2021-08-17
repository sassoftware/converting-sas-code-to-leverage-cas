/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
cas;
caslib _all_ assign;

proc cas;
   loadactionset "fcmpact";
   setSessOpt{cmplib="casuser.examples"};
run;                                                                                        

source ex_code;
function ex_add(a, b);

   C = a+b;

   return(C);

return(P);
endfunc;
endsource;

fcmpact.addRoutines /
   saveTable   = true,                                                                                                               
   funcTable   = {name="examples", caslib="casuser", replace=true},                                                                
   package     = "myPackage",                                                                                                        
   routineCode = ex_code;                                                                                                           
run;
quit;
 
libname sascas1 cas caslib=casuser;

options cmplib=sascas1.examples;

data sascas1.blah;
   value = ex_add(1,2);
   output;
run;

proc print data=sascas1.blah;
run;
run;
