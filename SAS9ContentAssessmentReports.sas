/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/*
Modify line 12 - to point to your SAS 9 Content Assessment published code check data mart.
Modify line 16 - to your AES encryptkey value if the data mart is encrypted, or remove the data sets option if the data mart is not encrypted.
Note: if using SAS proprietary encryption modify the data set option on line 16 to (encrypt=yes read=yourEncryptKey)
Always run in batch; this is due to the size of the reports. 
Reports are written to the path set on line 11.
*/
%let s9cadm = /path/to/S9CA/assessment/datamart/codecheck/;
%put &s9cadm.;
libname cc "&s9cadm.";
 
proc sort data=cc.codechk_issues (encrypt=AES encryptkey='1D57933958C58006055CEC080DD5D2A9') 
   out=work.codechk_issues (compress=binary keep=pgm_name element engine line n codeCheck_issue);
   by  pgm_name engine element;
run;

%macro element(element=lIBNAME);
title "&element.";
ods html5 file="&s9cadm.&element..html";
proc print data=codechk_issues(where=(element="&element")) label;
   var   n line pgm_name;
   label pgm_name='Full Program Name'  
         line='Source Code Statement' 
   		    n='Statement Line Number'; 
run;
ods html5 close;
title;
%mend element;

%macro engines;
title "Access Engines";
ods html5 file="&s9cadm.AccessEngines.html";
proc print data=codechk_issues(where=(element="LIBNAME")) label;
   var  n engine line pgm_name;
   label pgm_name='Full Program Name'  
         engine='Access Engine'  
         line='Source Code Statement' 
      		 n='Statement Line Number'; 
run;
ods html5 close;
title;
%mend engines;

%macro issues;
title "Issues for Review";
ods html5 file="&s9cadm.IssuesForReview.html";
proc print data=codechk_issues(where=(codeCheck_issue=1)) label;
   var  n element engine line pgm_name;
   label pgm_name='Full Program Name'
         element='Coding Element'   
         engine='Access Engine'  
         line='Source Code Statement' 
      		 n='Statement Line Number'; 
run;
ods html5 close;
title;
%mend issues;

options pagesize=max;

%engines;

%element(element=FILE);
%element(element=FILENAME);
%element(element=INFILE);
%element(element=LIBNAME);
%element(element=%INCLUDE);
%element(element=XCOMMAND);
%issues;
