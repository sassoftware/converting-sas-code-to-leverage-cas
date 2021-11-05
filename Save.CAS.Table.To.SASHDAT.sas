/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* Best practice to save a CAS table as a SASHDAT table */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;

%put  &_sessref_;

/* CASLIB for SASHDAT */
proc cas;
   table.addCaslib /
   caslib='sashdat'
   dataSource={srctype='DNFS'}
   path="/path/to/save/cas/table" 
   session=false;
quit;

/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;

/* Load CAS table */
proc casutil;
   load casdata='baseball.sashdat' outcaslib='casuser' casout='baseball' replace;
quit;

/* Two ways to save a CAS table to SASHDAT */
proc cas;
   table.save / caslib='sashdat'
   table={name='baseball', caslib='casuser'},
   name='baseball.sashdat'
   replace=True;
quit;

proc casutil;
   save casdata='baseball' incaslib='casuser'
   casout='baseball.sashdat' outcaslib='sashdat'
   replace;
quit;
