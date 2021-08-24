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

/* set the active CASLIB that you want the formats written to */
options caslib="public";

proc format casfmtlib="casformats";
   value dow
      1 = 'Sunday'
      2 = 'Monday'
      3 = 'Tuesday'
      4 = 'Wednesday'
      5 = 'Thursday'
      6 = 'Friday'
      7 = 'Saturday';
run;

/* Save format so they can be used between CAS sessions */
cas casauto savefmtlib fmtlibname=casformats table=dow replace;

cas casauto promotefmtlib fmtlibname='casformats' replace;

/* list user defined format defined to CAS */
cas casauto listfmtranges fmtname=dow;

proc cas; 
   accessControl.assumeRole / adminRole="SuperUser"; run;      
   configuration.setServOpt / fmtsearch = 'sassuppliedformats casformats';        
   configuration.getServOpt  result=new/ name="fmtsearch";     
run;
quit; 
