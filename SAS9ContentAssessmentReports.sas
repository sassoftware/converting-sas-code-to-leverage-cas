/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/*
Modify line 11 to point to your SAS 9 Content Assessment published code check data mart.
Modify line 15 encryptkey if encrypted, or remove the encryptkey data sets option if not encrypted.
Always run in batch; this is due to the size of the reports. 
Reports are written to the path set on line 11.
*/
%let s9cadm = /path/to/S9CA/assessment/datamart/codecheck/;
%put &s9cadm.;
libname cc "&s9cadm.";
 
 proc sort data=cc.codechk_issues (encryptkey='1D57933958C58006055CEC080DD5D2A9') 
   out=work.codechk_issues (compress=binary);
   by  pgm_name engine element;
run;

%macro element(element=lIBNAME);
title "&element.";
ods html5 file="&s9cadm.&element..html";
proc print data=codechk_issues(where=(element="&element")) label;
   var pgm_name line n ;
   label n='Statement Line Number'
         element='Coding Element'
	 	 line='Source Code Statement'
         pgm_name='Full Program Name';
run;
ods html5 close;
title;
%mend element;

%macro engines;
title "Access Engines";
ods html5 file="&s9cadm.AccessEngines.html";
proc print data=codechk_issues(where=(element="LIBNAME" and engine not in ('BASE','V9'))) label;
   var pgm_name engine line n ;
   label n='Statement Line Number'
         element='Coding Element'
		 engine='Access Engine'
		 line='Source Code Statement'
         pgm_name='Full Program Name';
run;
ods html5 close;
title;
%mend engines;

%macro issues;
title "Issues for Review";
ods html5 file="&s9cadm.IssuesForReview.html";
proc print data=codechk_issues(where=(codeCheck_issue=1)) label;
   var pgm_name element engine line n ;
   label n='Statement Line Number'
         element='Coding Element'
		 engine='Access Engine'
		 line='Source Code Statement'
         pgm_name='Full Program Name';
run;
ods html5 close;
title;
%mend issues;

%element(element=FILE);
%element(element=FILENAME);
%element(element=INFILE);
%element(element=LIBNAME);
%element(element=%INCLUDE);
%element(element=XCOMMAND);
%engines;
%issues;
