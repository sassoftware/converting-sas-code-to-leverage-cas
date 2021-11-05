/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* CAS Enabled */
/* Best practice to parallel load a SASHDAT table into a CAS table */

/* LIBNAME using the CAS engine */
libname CASWORK cas caslib=casuser;
/* Changing the default location of all one level named tables */
/* from SASWORK to CASWORK */
options USER = CASWORK;

%put  &_sessref_;

proc cas;
   table.addCaslib /
   caslib='sashdat'
   dataSource={srctype='DNFS'}
   path="/path/to/save/cas/table" 
   session=false;
quit;

/* Binds all CAS librefs and default CASLIBs to your SAS client */
caslib _all_ assign;

/* Note: You need to submit the SAS program Save.CAS.Table.To.SASHDAT before running this step */
proc casutil;
   load casdata='baseball.sashdat' outcaslib='casuser' casout='baseball' replace;
quit;

/* Set the active CASLIB to CASUSER */
options caslib='casuser';
