/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled*/
/* Example of using DATA Step to partition and order a CAS table */
/* Benfit, when a BY statement mactes the partition and ordering, */
/* the data is immediately ready for processing by each thread */
/* If the BY statment does not math the partition and ordering then their is a */
/* cost i.e. the BY is done on the fly to group the data correctly on each thread */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;
%put  &_sessref_;

data caswork.baseball(partition=(div row_order) orderby=(div row_order));
   set sashelp.baseball;
   row_order = _n_;
run;

/* Retain */
data caswork.baseball2;
   set caswork.baseball;
   retain count;
   BY DIV TEAM; 
   if first.team then 
     count=0;
   count+1;
run;
