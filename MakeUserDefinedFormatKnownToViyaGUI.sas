/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
 /*
In order to access user defined formats in SAS Visual Analystics, 
you would need to add them to the User defined formats in SAS Environment Manager 
or use the following code which will add the format to the search path. 
*/  

cas;
caslib _all_ assign;
 
proc cas; 
   accessControl.assumeRole / adminRole="SuperUser"; run;      
   configuration.setServOpt / fmtsearch = 'sassuppliedformats casformats';        
   configuration.getServOpt  result=new/ name="fmtsearch";     
run;
quit; 
