/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* How to convert character data type into varchar data type when lifting a table into CAS */ 
/* To reduce the size of CAS tables consider converting CHARACTER data into VARCHAR data using PROC CASUTIL IMPORTOPTIONS VARCHARCONVERSION= statement */
/* This example uses a data set as the source table being lifted into CAS */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;

%put  &_sessref_; 

proc cas;
  file log;
   table.dropCaslib /
   caslib='sas7bdat' quiet = true;
run;
   table.dropCaslib /
   caslib='sashdat' quiet = true;
run;
  addcaslib /
    datasource={srctype="path"}
    name="sas7bdat"
    path="&datapath" ; 
 run;
quit;
/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign; 

data sas7bdat.table_with_char;
   length a $ 300 b $ 15 c $ 16;
   a='a300'; b='b15' ; c='c16' ; output;
   a='a300300'; b='b151515'; c='c161616'; output;
   c='c161616161616161'; 
   b='b15151515151515';
   a="a300qzwsxedcrfvtgbyhnujmiklopqazwsxedcrfvtgbyhnujmikolp12345678901234567890123456789012345678901234567890123456789012345678901234567890"; output;
run;


proc casutil;
               load casdata="table_with_char.sas7bdat" incaslib="sas7bdat" outcaslib="casuser"
               casout="table_with_varchar" importoptions=(filetype="basesas" varcharconversion=16) replace;
run;

proc cas;
   sessionProp.setSessOpt /
   caslib="casuser";
run;
   table.columninfo / table="table_with_varchar";
quit;
