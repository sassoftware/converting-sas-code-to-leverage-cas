/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* Best practice to save a CAS table as a SAS7BDAT table */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;

%put  &_sessref_;

/* CASLIB for SAS7BDAT data sets */
proc cas;
   table.dropCaslib /
   caslib='sashdat' quiet = true;
run;
   table.addCaslib /
   caslib='sas7bdat'
   dataSource={srctype='path'}
   path="&datapath";
run;
quit;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;

/* Two ways to save a CAS table as a SAS7BDAT */
proc cas;
   table.save / caslib='sas7bdat'
   table={name='baseball', caslib='casuser'},
   name='baseball.sas7bdat'
   replace=True;
quit;

/*How to save a CAS table as a compress sas7bdat */
proc casutil;
   save casdata='baseball' incaslib='casuser'
   casout='baseball.sas7bdat' outcaslib='sas7bdat'
   exportoptions=(filetype='basesas', compress='yes' debug='dmsglvli') 
   replace;
quit;


/* Set active CASLIB to CASUSER */
options caslib='casuser';
